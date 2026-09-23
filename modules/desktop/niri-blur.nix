# Background blur behind every window and behind Noctalia's surfaces
# (niri >= 26.04, background-effect). Blur only shows through the
# translucent parts of a surface: an opaque window looks unchanged.
#
# niri-flake's settings have no background-effect yet, so the rules are
# appended as raw KDL nodes to the document rendered from
# programs.niri.settings (options...config.default); defining
# programs.niri.config replaces that default, hence the explicit ++.
#
# Layers: Noctalia's niri page list (bar, notifications, dock, panels, OSD),
# with xray off so they blur the windows beneath them, not only the
# wallpaper. The wallpaper and the unframed desktop widgets are left out:
# a blurred rectangle would show behind the widgets.
{ inputs, ... }:
{
  den.aspects.desktop-niri-blur.provides.to-users.homeManager =
    { options, ... }:
    let
      inherit (inputs.niri.lib.kdl) plain leaf;
    in
    {
      programs.niri.config = options.programs.niri.config.default ++ [
        (plain "window-rule" [
          (plain "background-effect" [ (leaf "blur" true) ])
        ])
        (plain "layer-rule" [
          (leaf "match" {
            namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$";
          })
          (plain "background-effect" [
            (leaf "blur" true)
            (leaf "xray" false)
          ])
        ])
      ];
    };
}
