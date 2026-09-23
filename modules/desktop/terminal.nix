# terminal emulator for the desktop, spawned by Mod+T (niri-binds.nix).
# Ghostty runs as a single GTK instance: a plain `ghostty` (no CLI args, so
# gtk-single-instance = detect applies) hands the new window to the running
# instance over D-Bus, or becomes that instance itself.
# niri window rules match it by app-id "com.mitchellh.ghostty".
#
# The background is translucent and niri blurs what shows through it
# (niri-blur.nix); ghostty's own background-blur only acts on KDE and macOS.
# The font comes from fonts.nix.
{ ... }:
{
  den.aspects.desktop-terminal.provides.to-users.homeManager = {
    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = 12;
        background-opacity = 0.85;
        window-padding-x = 10;
        window-padding-y = 10;
      };
    };
  };
}
