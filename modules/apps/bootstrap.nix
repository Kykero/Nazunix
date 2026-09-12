# den-bootstrap v3: interactive live-ISO installer/updater, run as root from
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
#
# v3 adds an optional `nazunix-keys/` directory looked up on removable
# media (or pointed at with NAZUNIX_KEYS=/path). Nothing in it ever enters
# the repo; it only travels USB -> live ISO -> target disk:
#   id_ed25519, id_ed25519.pub          user SSH key (git push + signing),
#                                       installed to /root/.ssh on the ISO and
#                                       to /home/<user>/.ssh on the target
#   ssh_host_ed25519_key(.pub)          optional: pre-seeded sshd host key, so
#                                       the machine identity (and the age key
#                                       sops derives from it) is stable from
#                                       the first boot
# GitHub's published ed25519 host key is written to known_hosts on both
# sides so the first push never faces a TOFU prompt.
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

          # -- step 1b: optional nazunix-keys/ from removable media -------------
          # Looked up in this order: NAZUNIX_KEYS=/path, a directory the
          # graphical ISO already auto-mounted under /run/media, then every
          # partition of a removable device mounted read-only for a look
          # (a second stick, or a Ventoy data partition next to the ISO --
          # a dd-written ISO is read-only, so the keys can't live on it).
          # Whatever is found is copied to a root-only tmpdir so the media
          # can be unmounted and pulled right away.
          KEYS=""
          github_known_host='github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl'

          stash_keys() {
            local from=$1
            KEYS=$(mktemp -d /root/nazunix-keys.XXXXXX)
            chmod 700 "$KEYS"
            cp -a "$from/." "$KEYS/"
          }

          if [ -n "''${NAZUNIX_KEYS:-}" ]; then
            [ -d "$NAZUNIX_KEYS" ] || die "NAZUNIX_KEYS=$NAZUNIX_KEYS is not a directory"
            stash_keys "$NAZUNIX_KEYS"
          else
            for d in /run/media/*/*/nazunix-keys /media/*/nazunix-keys; do
              if [ -d "$d" ]; then
                stash_keys "$d"
                break
              fi
            done
          fi

          if [ -z "$KEYS" ]; then
            probe=$(mktemp -d)
            while read -r part; do
              mount -o ro "$part" "$probe" 2>/dev/null || continue
              if [ -d "$probe/nazunix-keys" ]; then
                stash_keys "$probe/nazunix-keys"
              fi
              umount "$probe"
              [ -z "$KEYS" ] || break
            done < <(lsblk -nrpo NAME,TYPE,RM | awk '$2 == "part" && $3 == "1" {print $1}')
            rmdir "$probe"
          fi

          user_key=0
          host_key=0
          if [ -n "$KEYS" ]; then
            if [ -f "$KEYS/id_ed25519" ] && [ -f "$KEYS/id_ed25519.pub" ]; then
              user_key=1
              # on the ISO too: commit signing and push (later steps) run here
              install -d -m 700 /root/.ssh
              install -m 600 "$KEYS/id_ed25519" /root/.ssh/id_ed25519
              install -m 644 "$KEYS/id_ed25519.pub" /root/.ssh/id_ed25519.pub
              grep -qF "$github_known_host" /root/.ssh/known_hosts 2>/dev/null \
                || printf '%s\n' "$github_known_host" >> /root/.ssh/known_hosts
            fi
            if [ -f "$KEYS/ssh_host_ed25519_key" ] && [ -f "$KEYS/ssh_host_ed25519_key.pub" ]; then
              host_key=1
            fi
            gum style --foreground 33 \
              "nazunix-keys found: user key $([ "$user_key" -eq 1 ] && echo yes || echo no), host key $([ "$host_key" -eq 1 ] && echo yes || echo no)"
          else
            gum style --foreground 220 "no nazunix-keys directory found -- keys will not be installed"
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

          # -- step 13b: keys onto the target ---------------------------------------
          if [ "$user_key" -eq 1 ]; then
            install -d -m 700 "/mnt/home/$user/.ssh"
            install -m 600 "$KEYS/id_ed25519" "/mnt/home/$user/.ssh/id_ed25519"
            install -m 644 "$KEYS/id_ed25519.pub" "/mnt/home/$user/.ssh/id_ed25519.pub"
            printf '%s\n' "$github_known_host" > "/mnt/home/$user/.ssh/known_hosts"
            chmod 644 "/mnt/home/$user/.ssh/known_hosts"
            nixos-enter --root /mnt -c "chown -R $user:users /home/$user/.ssh"
            gum style --foreground 33 "installed user SSH key to /home/$user/.ssh"
          fi
          if [ "$host_key" -eq 1 ]; then
            # sshd only generates host keys when none exist, so pre-seeding
            # here makes the machine identity stable from the first boot
            install -d -m 755 /mnt/etc/ssh
            install -m 600 "$KEYS/ssh_host_ed25519_key" /mnt/etc/ssh/ssh_host_ed25519_key
            install -m 644 "$KEYS/ssh_host_ed25519_key.pub" /mnt/etc/ssh/ssh_host_ed25519_key.pub
            gum style --foreground 33 "installed sshd host key to /etc/ssh"
          fi

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
