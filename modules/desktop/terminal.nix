# terminal emulator for the desktop, spawned by Mod+T (niri-binds.nix).
# Ghostty runs as a single GTK instance: a plain `ghostty` (no CLI args, so
# gtk-single-instance = detect applies) hands the new window to the running
# instance over D-Bus, or becomes that instance itself.
# niri window rules match it by app-id "com.mitchellh.ghostty".
#
# The background is translucent and niri blurs what shows through it
# (niri-blur.nix); ghostty's own background-blur only acts on KDE and macOS.
# The font comes from fonts.nix.
#
# Colours come from Noctalia's Ghostty template (enable it in Noctalia's GUI:
# Settings > Theming > Templates > Ghostty). It writes themes/noctalia and
# its hook adds `theme = noctalia` to the config unless already there, then
# reloads ghostty. The line is set here, so the hook never touches the
# read-only config and only reloads. home-manager's `+validate-config`
# onChange is dropped: it fails the activation while the theme file does not
# exist yet, where ghostty itself only warns and keeps its default colours.
{ lib, ... }:
{
  den.aspects.desktop-terminal.provides.to-users.homeManager = {
    xdg.configFile."ghostty/config".onChange = lib.mkForce "";

    programs.ghostty = {
      enable = true;
      settings = {
        theme = "noctalia";
        font-family = "JetBrainsMono Nerd Font";
        font-size = 12;
        background-opacity = 0.85;
        window-padding-x = 10;
        window-padding-y = 10;
        # ghostty's default fullscreen toggle; niri's Mod+Shift+F already
        # does it (niri-binds.nix), and ctrl+enter then reaches the shell
        keybind = [ "ctrl+enter=unbind" ];
      };
    };
  };
}
