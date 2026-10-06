# Noctalia shell (bar, launcher, notifications, lock screen) on top of niri.
# noctalia/config.toml is the declarative base layer, linked read-only into
# ~/.config/noctalia; the GUI still owns ~/.local/state/noctalia/settings.toml,
# which overrides it.
# pkgs.noctalia (v5) comes from nixpkgs, so cache.nixos.org has it -- no
# extra flake input, no extra substituter. pkgs.noctalia-shell is the dead v4.
{ ... }:
{
  den.aspects.desktop-noctalia.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.noctalia ];

      xdg.configFile."noctalia/config.toml" = {
        source = ./noctalia/config.toml;
        # replaces the hand-written copy predating this module
        force = true;
      };

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
