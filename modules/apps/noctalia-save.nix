# den-noctalia-save: snapshots this machine's Noctalia config (config.toml
# merged with the GUI's settings.toml, as `noctalia config export` prints it)
# into modules/desktop/noctalia/<host>.toml and commits it when it changed.
# That file seeds the machine again after a reinstall (desktop/noctalia.nix).
# Run by den-rebuild before it pulls; usable on its own.
{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.den-noctalia-save = pkgs.writeShellApplication {
        name = "den-noctalia-save";
        runtimeInputs = [
          pkgs.noctalia
          pkgs.git
        ];
        text = ''
          cd "''${NH_OS_FLAKE:-''${NH_FLAKE:?set by programs.nh}}" || exit 1

          # -base hosts never ran Noctalia: nothing worth a snapshot
          if [ ! -e "$HOME/.config/noctalia/config.toml" ] \
            && [ ! -e "$HOME/.local/state/noctalia/settings.toml" ]; then
            exit 0
          fi

          host=$(cat /proc/sys/kernel/hostname)
          out="modules/desktop/noctalia/$host.toml"
          tmp=$(mktemp)
          trap 'rm -f "$tmp"' EXIT

          {
            echo "# $host's Noctalia config, written by den-noctalia-save (noctalia config export)."
            echo "# Seeds ~/.config/noctalia/config.toml on a fresh $host; edit from the GUI instead."
            echo
            noctalia config export
          } > "$tmp"
          noctalia config validate "$tmp" >/dev/null

          if cmp -s "$tmp" "$out"; then
            exit 0
          fi
          install -m 644 "$tmp" "$out"
          git add -- "$out"
          git commit -q -m "chore(noctalia): snapshot $host config" -- "$out"
          echo "noctalia: $out updated and committed"
        '';
      };
    };
}
