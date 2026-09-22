# niri window rules. niri-flake names the option window-rules (a list, one
# attrset per KDL `window-rule` node); a rule without `matches` applies to
# every window.
#
# geometry-corner-radius is a record of four floats in niri-flake (4.0, not
# 4, and no single-number shorthand as in KDL). clip-to-geometry cuts the
# window contents to those rounded corners, not just the focus ring.
{ ... }:
{
  den.aspects.desktop-niri-window-rules.provides.to-users.homeManager = {
    # server-side decorations: GTK apps (ghostty) drop their own headerbar and
    # rounded shadow and learn they are tiled, so the rule below is the only
    # thing rounding their corners
    programs.niri.settings.prefer-no-csd = true;

    programs.niri.settings.window-rules = [
      {
        geometry-corner-radius = {
          top-left = 4.0;
          top-right = 4.0;
          bottom-right = 4.0;
          bottom-left = 4.0;
        };
        clip-to-geometry = true;
      }
    ];
  };
}
