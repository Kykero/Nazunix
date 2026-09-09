# den-bootstrap v2: interactive live-ISO installer/updater, run as root from
# the NixOS installer ISO. Unlike v1, nothing host-specific is baked in at
# Nix eval time (no more den.hosts / inputs.self lookups here) -- hostname,
# user, disk, RAM and caches are all discovered or chosen at run time
# against a fresh clone of this repo (SRC), which is what lets the script
# create a brand-new host, not just install one already declared in
# modules/hosts.nix. New hosts are rendered from templates/host/*.in and
# spliced into modules/hosts.nix just above the
# "den-bootstrap inserts new hosts above this line" marker. The script
# never commits or pushes: it only stages (git add -A) so the flake sees
# the new/updated files, installs from that local checkout, then copies the
# checkout (staged changes included) to the target's /home/<user>/Nazunix
# for the operator to commit and push after first boot, with their own
# identity and signing key.
{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      packages.den-bootstrap = pkgs.writeShellApplication {
        name = "den-bootstrap";
        runtimeInputs = [
          pkgs.gum
          pkgs.git
          pkgs.curl
          pkgs.util-linux
          pkgs.procps
          pkgs.gawk
          pkgs.gnused
          pkgs.gnugrep
          pkgs.coreutils
          pkgs.nixos-install
          pkgs.nixos-enter
          inputs.disko.packages.${system}.disko
        ];
        # nixos-generate-config (used below) has no top-level
        # `pkgs.nixos-generate-config` attribute in nixpkgs -- verified via
        # Context7 (/nixos/nixpkgs): it's built per-configuration by
        # nixos/modules/installer/tools/tools.nix (a `makeProg` wrapper),
        # not a plain derivation, unlike nixos-install/nixos-enter above
        # which are real top-level packages. writeShellApplication prepends
        # runtimeInputs to the *inherited* PATH rather than replacing it,
        # and the live ISO ships nixos-generate-config by default, so it
        # resolves at run time without being listed here.
        text = ''
          # disko shells out to nix itself, and the live ISO ships with
          # experimental-features empty by default -- export this once so
          # every nix invocation below (disko's, nixos-install's, and ours)
          # sees it.
          export NIX_CONFIG="experimental-features = nix-command flakes"

          die() {
            echo "error: $*" >&2
            exit 1
          }

          # guarded gum choose: reads items from args (one per line) so a
          # cancelled picker (Esc) dies with a message instead of silently
          # propagating an empty string under errexit + pipefail
          choose() {
            local header=$1
            shift
            printf '%s\n' "$@" | gum choose --header "$header"
          }

          # -- step 0: preflights -------------------------------------------
          [ "$(id -u)" = 0 ] || die "run as root (sudo -i)"
          [ -d /sys/firmware/efi/efivars ] || die "not booted in UEFI mode"
          curl -fsS --max-time 5 https://cache.nixos.org/nix-cache-info >/dev/null \
            || die "no network reachable"

          # -- step 1: clone or refresh the source checkout ------------------
          SRC=/root/nazunix-src
          if [ -d "$SRC/.git" ]; then
            if [ -n "$(git -C "$SRC" status --porcelain)" ]; then
              if gum confirm "keep local changes from a previous run in $SRC?"; then
                echo "keeping local changes in $SRC" >&2
              else
                git -C "$SRC" reset --hard origin/main
                git -C "$SRC" clean -fd
                git -C "$SRC" pull --ff-only
              fi
            else
              git -C "$SRC" pull --ff-only
            fi
          else
            git clone https://github.com/Kykero/Nazunix "$SRC"
          fi

          # -- step 2: host ---------------------------------------------------
          existing_hosts=()
          for d in "$SRC"/modules/hosts/*/; do
            [ -d "$d" ] && existing_hosts+=("$(basename "$d")")
          done

          host=$(choose "host to install" "''${existing_hosts[@]}" "new host") \
            || die "aborted: no host chosen"

          new_host=0
          if [ "$host" = "new host" ]; then
            new_host=1
            host=$(gum input --placeholder "hostname") \
              || die "aborted: no hostname entered"
            [[ "$host" =~ ^[a-z][a-z0-9-]*$ ]] \
              || die "invalid hostname: $host (expected [a-z][a-z0-9-]*)"
            [[ "$host" != *-base ]] || die "hostname must not end in -base"
            for h in "''${existing_hosts[@]}"; do
              [ "$h" != "$host" ] || die "host $host already exists"
            done
          fi

          # -- step 3: user -----------------------------------------------------
          users=()
          for f in "$SRC"/modules/users/*.nix; do
            [ -e "$f" ] && users+=("$(basename "$f" .nix)")
          done
          [ "''${#users[@]}" -gt 0 ] || die "no user modules found under modules/users"

          if [ "''${#users[@]}" -eq 1 ]; then
            user="''${users[0]}"
          else
            user=$(choose "user for $host" "''${users[@]}") \
              || die "aborted: no user chosen"
          fi

          # anchored on the host's own registry line so a second user module
          # can't pass on the strength of another host's declaration
          if [ "$new_host" -eq 0 ]; then
            grep -qE "^[[:space:]]*$host\.users\.$user([[:space:]]|=)" "$SRC/modules/hosts.nix" \
              || die "host $host does not declare user $user in modules/hosts.nix"
          fi

          # -- step 4: disk -----------------------------------------------------
          # -d: top-level devices only (skips partitions); -n: no header;
          # -p: full /dev path in NAME; keep TYPE==disk and RM==0, which
          # drops the live USB itself along with partitions/loop devices
          mapfile -t disks < <(lsblk -dnpo NAME,SIZE,TYPE,RM,MODEL | awk '
            $3 == "disk" && $4 == "0" {
              name = $1; size = $2; model = "";
              for (i = 5; i <= NF; i++) model = model (model == "" ? "" : " ") $i;
              print name, size, model;
            }')
          [ "''${#disks[@]}" -gt 0 ] || die "no candidate disks found -- check lsblk output"

          disk_line=$(choose "disk to install $host on (ERASES its content)" "''${disks[@]}") \
            || die "aborted: no disk chosen"
          device=$(awk '{print $1}' <<< "$disk_line")
          [ -b "$device" ] || die "$device not found -- check lsblk output"

          # -- step 5: RAM / zram ------------------------------------------------
          mem_kib=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo) \
            || die "failed to read /proc/meminfo"
          zram=0
          [ "$mem_kib" -lt $((16 * 1024 * 1024)) ] && zram=1

          # -- step 6: hardware.nix -----------------------------------------------
          # mkdir here (not just in the "new host" branch below): a brand-new
          # host has no directory yet, and hardware.nix must land before
          # host.nix/disko.nix are rendered into it
          mkdir -p "$SRC/modules/hosts/$host"

          hw=$(nixos-generate-config --no-filesystems --show-hardware-config) \
            || die "nixos-generate-config failed"

          # keep only boot.* / hardware.* lines: kernel modules, microcode,
          # firmware -- never MACs/serials, which generate-config's
          # --show-hardware-config never prints anyway. This also drops
          # networking.*, nixpkgs.hostPlatform, fileSystems, swapDevices.
          hw_lines=$(printf '%s\n' "$hw" | grep -E '^[[:space:]]*(boot\.|hardware\.)' || true)
          [ -n "$hw_lines" ] || die "nixos-generate-config produced no boot./hardware. lines"

          hw_lines_indented=$(printf '%s\n' "$hw_lines" | sed -E 's/^[[:space:]]*/      /')

          hw_file="$SRC/modules/hosts/$host/hardware.nix"
          {
            printf '%s\n' '# generated by den-bootstrap from `nixos-generate-config --no-filesystems'
            printf '%s\n' '# --show-hardware-config` -- kernel modules and microcode only, no serials'
            printf '%s\n' '{ ... }:'
            printf '%s\n' '{'
            printf '  den.aspects.%s-hw.nixos =\n' "$host"
            printf '%s\n' '    { config, lib, modulesPath, ... }:'
            printf '%s\n' '    {'
            printf '%s\n' '      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];'
            printf '%s\n' "$hw_lines_indented"
            printf '%s\n' '    };'
            printf '%s\n' '}'
          } > "$hw_file"

          gum style --foreground 33 "generated $hw_file --"
          cat "$hw_file"

          # -- step 7: render templates (new host) or patch disko (existing) -----
          if [ "$new_host" -eq 1 ]; then
            sed -e "s/@@HOST@@/$host/g" -e "s/@@USER@@/$user/g" \
              "$SRC/templates/host/host.nix.in" > "$SRC/modules/hosts/$host/$host.nix"
            if [ "$zram" -eq 1 ]; then
              sed -i 's/ # @@ZRAM@@$//' "$SRC/modules/hosts/$host/$host.nix"
            else
              sed -i '/# @@ZRAM@@$/d' "$SRC/modules/hosts/$host/$host.nix"
            fi

            sed -e "s/@@HOST@@/$host/g" -e "s#@@DEVICE@@#$device#g" \
              "$SRC/templates/host/disko.nix.in" > "$SRC/modules/hosts/$host/disko.nix"

            grep -q '# den-bootstrap inserts new hosts above this line' "$SRC/modules/hosts.nix" \
              || die "marker line missing in modules/hosts.nix -- cannot register $host"
            entry=$(sed -e "s/@@HOST@@/$host/g" -e "s/@@USER@@/$user/g" \
              "$SRC/templates/host/hosts-entry.nix.in")
            awk -v entry="$entry" '
              /# den-bootstrap inserts new hosts above this line/ { print entry }
              { print }
            ' "$SRC/modules/hosts.nix" > "$SRC/modules/hosts.nix.new"
            mv "$SRC/modules/hosts.nix.new" "$SRC/modules/hosts.nix"
          else
            disko_file="$SRC/modules/hosts/$host/disko.nix"
            n=$(grep -c 'device = "' "$disko_file" || true)
            [ "$n" -eq 1 ] || die "$disko_file: expected exactly one device line, found $n"
            # .* also drops any trailing "confirm with lsblk" TODO: it is confirmed now
            sed -i "s|device = \"/dev/[^\"]*\";.*|device = \"$device\";|" "$disko_file"
          fi

          # -- step 8: review the staged diff -------------------------------------
          git -C "$SRC" add -A
          git -C "$SRC" diff --cached --stat

          if ! git -C "$SRC" diff --cached | gum pager; then
            git -C "$SRC" --no-pager diff --cached
          fi

          gum confirm --default=false "files look right?" \
            || die "aborted -- review the staged changes in $SRC and re-run"

          # -- step 9: validate before touching the disk --------------------------
          entity="$host-base"

          gum spin --title "evaluating $entity toplevel..." --show-error -- \
            nix eval "$SRC#nixosConfigurations.$entity.config.system.build.toplevel.drvPath" \
            || die "eval failed for $entity -- fix the config before installing (nothing was touched)"

          subs=$(nix eval --raw "$SRC#nixosConfigurations.$entity.config.nix.settings.substituters" \
            --apply 'builtins.concatStringsSep " "') \
            || die "failed to read substituters for $entity"
          keys=$(nix eval --raw "$SRC#nixosConfigurations.$entity.config.nix.settings.trusted-public-keys" \
            --apply 'builtins.concatStringsSep " "') \
            || die "failed to read trusted keys for $entity"

          # -- step 10: /mnt guard + confirmation banner --------------------------
          if mountpoint -q /mnt; then
            gum confirm "unmount /mnt from a previous attempt?" \
              || die "aborted: /mnt already mounted"
            umount -R /mnt
          fi

          zram_label=no
          [ "$zram" -eq 1 ] && zram_label=yes
          status_label=new
          [ "$new_host" -eq 0 ] && status_label=updated

          gum style --foreground 196 --border double --padding "1 2" \
            "host: $host ($status_label)" \
            "entity: $entity" \
            "user: $user" \
            "device: $device" \
            "RAM: $(free -h | awk '/Mem:/{print $2}'), zram: $zram_label" \
            "ERASE ALL DATA ON $device"
          gum confirm --default=false "Proceed? This is IRREVERSIBLE." \
            || die "aborted"

          # -- step 11-12: partition, format, install ------------------------------
          disko --mode destroy,format,mount --yes-wipe-all-disks --flake "$SRC#$entity"

          nixos-install --root /mnt --flake "$SRC#$entity" \
            --no-root-password --no-channel-copy \
            --option extra-substituters "$subs" \
            --option extra-trusted-public-keys "$keys"

          # -- step 13: copy the checkout onto the target --------------------------
          mkdir -p "/mnt/home/$user" # never chmod a home nixos-install already created
          cp -a "$SRC" "/mnt/home/$user/Nazunix"
          nixos-enter --root /mnt -c "chown -R $user:users /home/$user/Nazunix"

          # -- step 14: password ---------------------------------------------------
          # NixOS manual's recommended way to set a first-login password;
          # never an initialPassword in the repo
          gum style --foreground 220 "setting the password for $user -- you will be prompted now"
          nixos-enter --root /mnt -c "passwd $user"

          # -- step 15: done --------------------------------------------------------
          gum style --foreground 42 --border double --padding "1 2" \
            "done. remove installation media and reboot, then log in as $user:" \
            "  cd ~/Nazunix && git status" \
            "  # commit the new/updated host files with your own identity and push -- CI evaluates" \
            "  nix run ~/Nazunix#den-warm" \
            "  nh os switch"
        '';
      };
    };
}
