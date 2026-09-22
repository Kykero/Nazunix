# terminal emulator for the desktop, spawned by Mod+T (niri-binds.nix).
# Ghostty runs as a single GTK instance: a plain `ghostty` (no CLI args, so
# gtk-single-instance = detect applies) hands the new window to the running
# instance over D-Bus, or becomes that instance itself.
# niri window rules match it by app-id "com.mitchellh.ghostty".
{ ... }:
{
  den.aspects.desktop-terminal.provides.to-users.homeManager = {
    programs.ghostty.enable = true;
  };
}
