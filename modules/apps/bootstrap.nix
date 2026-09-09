# den-bootstrap: interactive live-ISO installer, run as root from the
# NixOS installer ISO. Per-entity install facts (hostname, disk device,
# caches) are baked in from this flake's own built configs at Nix eval
# time, then the script drives disko + nixos-install off a single git
# clone reused for both the ephemeral install source and the target's
# /home/nazuna/Nazunix checkout that nh (modules/nh.nix) expects on
# first boot.
{ inputs, den, lib, ... }:
let
  baseHosts = lib.filterAttrs (_: h: h.profile == "base") den.hosts.x86_64-linux;
  entities = lib.attrNames baseHosts;
  cfgFor = name: inputs.self.nixosConfigurations.${name}.config;

  # entity-name -> string, rendered as a `declare -A` bash literal,
  # keyed and value-quoted with escapeShellArg
  bashAssoc =
    f:
    "(" + lib.concatMapStringsSep " " (n: "[${lib.escapeShellArg n}]=${lib.escapeShellArg (f n)}") entities + ")";
in
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
          pkgs.nixos-install
          pkgs.nixos-enter
          inputs.disko.packages.${system}.disko
        ];
        text = ''
          # disko shells out to nix itself, and the live ISO ships with
          # experimental-features empty by default -- export this once so
          # every nix invocation below (disko's and nixos-install's) sees it.
          export NIX_CONFIG="experimental-features = nix-command flakes"

          [ "$(id -u)" = 0 ] || { echo "error: run as root (sudo -i)" >&2; exit 1; }
          [ -d /sys/firmware/efi/efivars ] || { echo "error: not booted in UEFI mode" >&2; exit 1; }
          curl -fsS --max-time 5 https://cache.nixos.org/nix-cache-info >/dev/null \
            || { echo "error: no network reachable" >&2; exit 1; }

          # NOTE on staleness: these associative arrays are baked at Nix eval
          # time (T1 -- whenever this den-bootstrap package was last built or
          # fetched), read straight off inputs.self.nixosConfigurations. The
          # actual install below re-clones the flake fresh at run time (T2,
          # the $SRC checkout). If main moved between T1 and T2, disko and
          # nixos-install still act correctly on the live T2 config, but the
          # confirmation banner a few lines down could show a stale
          # hostname/disk/RAM-adjacent entity summary. Low risk for a single
          # -operator repo; re-running `nix run ...#den-bootstrap` refreshes it.
          declare -A HOSTNAMES=${bashAssoc (n: (cfgFor n).networking.hostName)}
          declare -A DEVICES=${bashAssoc (n: (cfgFor n).disko.devices.disk.main.device)}
          declare -A SUBSTITUTERS=${bashAssoc (n: lib.concatStringsSep " " (cfgFor n).nix.settings.substituters)}
          declare -A KEYS=${bashAssoc (n: lib.concatStringsSep " " (cfgFor n).nix.settings.trusted-public-keys)}
          ENTITIES=(${lib.escapeShellArgs entities})

          # guarded assignment: a cancelled picker (Esc) must say so instead of
          # dying silently under errexit + pipefail
          entity=$(printf '%s\n' "''${ENTITIES[@]}" \
            | gum choose --header "select entity to install (ERASES its disk)") \
            || { echo "aborted: no entity chosen" >&2; exit 1; }
          [ -v "HOSTNAMES[$entity]" ] || { echo "error: unknown entity '$entity'" >&2; exit 1; }

          disk="''${DEVICES[$entity]}"
          [ -b "$disk" ] || { echo "error: $disk not found. lsblk:" >&2; lsblk; exit 1; }

          if mountpoint -q /mnt; then
            if gum confirm "unmount /mnt from a previous attempt?"; then
              umount -R /mnt
            else
              echo "aborted: /mnt already mounted" >&2
              exit 1
            fi
          fi

          gum style --foreground 196 --border double --padding "1 2" \
            "install $entity (hostname ''${HOSTNAMES[$entity]})" \
            "ERASE ALL DATA ON $disk" \
            "this machine's RAM: $(free -h | awk '/Mem:/{print $2}')"
          gum confirm --default=false "Proceed? This is IRREVERSIBLE." \
            || { echo "aborted"; exit 1; }

          SRC=/root/nazunix-src
          if [ -d "$SRC/.git" ]; then
            git -C "$SRC" pull --ff-only
          else
            git clone https://github.com/Kykero/Nazunix "$SRC"
          fi

          disko --mode destroy,format,mount --yes-wipe-all-disks --flake "$SRC#$entity"

          install -d -m 0755 /mnt/home/nazuna
          git clone "$SRC" /mnt/home/nazuna/Nazunix
          git -C /mnt/home/nazuna/Nazunix remote set-url origin https://github.com/Kykero/Nazunix

          nixos-install --root /mnt --flake "/mnt/home/nazuna/Nazunix#$entity" \
            --no-root-password --no-channel-copy \
            --option extra-substituters "''${SUBSTITUTERS[$entity]}" \
            --option extra-trusted-public-keys "''${KEYS[$entity]}"

          nixos-enter --root /mnt -c 'chown -R nazuna:users /home/nazuna/Nazunix'

          gum style --foreground 42 \
            "done. remove installation media, reboot, log in as nazuna, then:" \
            "  nix run /home/nazuna/Nazunix#den-warm   (dazai only)" \
            "  nh os switch"
        '';
      };
    };
}
