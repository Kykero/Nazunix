# Noctalia shell (bar, launcher, notifications, lock screen) on top of niri.
# ~/.config/noctalia/config.toml is seeded once, writable, from
# noctalia/<host>.toml (the machine's last snapshot, see
# apps/noctalia-save.nix) or noctalia/base.toml, then left alone: each
# machine tunes its own (bar size, widget placement), from the GUI or by hand.
# pkgs.noctalia (v5) comes from nixpkgs, so cache.nixos.org has it -- no
# extra flake input, no extra substituter. pkgs.noctalia-shell is the dead v4.
{ ... }:
{
  den.aspects.desktop-noctalia.provides.to-users.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.noctalia ];

      # a symlink is a leftover from when home-manager owned the file
      home.activation.noctaliaConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        cfg="${config.xdg.configHome}/noctalia/config.toml"
        if [ ! -e "$cfg" ] || [ -L "$cfg" ]; then
          seed="${./noctalia}/$(cat /proc/sys/kernel/hostname).toml"
          [ -e "$seed" ] || seed="${./noctalia}/base.toml"
          run mkdir -p "$(dirname "$cfg")"
          run rm -f "$cfg"
          run install -m 644 "$seed" "$cfg"
        fi
      '';

      programs.niri.settings = {
        # upstream's recommended niri autostart
        spawn-at-startup = [ { argv = [ "noctalia" ]; } ];

        # lets notification actions and the launcher activate windows
        debug."honor-xdg-activation-with-invalid-serial" = [ ];

        # "stationary wallpaper" from Noctalia's niri page: the sharp wallpaper
        # itself sits in niri's backdrop, so the overview shows it as is, and
        # transparent workspaces keep it visible outside the overview too.
        # Noctalia's blurred [backdrop] layer stays off (its default).
        layer-rules = [
          {
            matches = [ { namespace = "^noctalia-wallpaper"; } ];
            place-within-backdrop = true;
          }
        ];
        layout.background-color = "transparent";
      };
    };
}
