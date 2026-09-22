# User-side niri config, everything except the binds (niri-binds.nix).
# niri-flake's homeModules.config turns programs.niri.settings into
# ~/.config/niri/config.kdl and runs `niri validate` on it at build time,
# against the package set here: nixpkgs' niri (v26.04), the same one the
# session runs. Values mirror niri's resources/default-config.kdl for that
# version, with the keyboard set to AZERTY; options are left out when the
# niri-flake default already equals the KDL default.
#
# A homeManager class on a host-included aspect is inert in den; the config
# reaches the host's users through provides.to-users.
{ inputs, ... }:
{
  den.aspects.desktop-niri-home.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      imports = [ inputs.niri.homeModules.config ];

      programs.niri.package = pkgs.niri;

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
          gaps = 12;
          center-focused-column = "never";
          # a lone column sits centered; from the second one on, "never" lays
          # the 0.5-wide columns side by side (50/50) with no recentering
          always-center-single-column = true;
          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
          ];
          default-column-width = {
            proportion = 0.5;
          };
          focus-ring = {
            enable = false;
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
