# User-side niri config, everything except the binds (niri-binds.nix).
# Mirrors niri's resources/default-config.kdl for the niri-stable niri-flake
# ships (v25.08), with the keyboard set to AZERTY. Options left at their
# niri-flake default when that default already equals default-config.kdl.
#
# A homeManager class on a host-included aspect is inert in den; the config
# reaches the host's users through provides.to-users.
{ ... }:
{
  den.aspects.desktop-niri-home.provides.to-users.homeManager = {
    programs.niri.settings = {
      input = {
        keyboard = {
          xkb.layout = "fr";
          numlock = true;
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
        };
      };

      layout = {
        gaps = 16;
        center-focused-column = "never";
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
        default-column-width = {
          proportion = 0.5;
        };
        focus-ring = {
          width = 4;
          active.color = "#7fc8ff";
          inactive.color = "#505050";
        };
        border = {
          enable = false;
          width = 4;
          active.color = "#ffc87f";
          inactive.color = "#505050";
          urgent.color = "#9b0000";
        };
      };

      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
    };
  };
}
