# X11 clients (Steam, Wine, older games) under niri. niri has no built-in
# Xwayland: since 25.08 it starts xwayland-satellite on demand when the binary
# is in PATH and exports DISPLAY to the session. Without it, X11 apps fail
# with "Unable to open a connection to X".
{ ... }:
{
  den.aspects.desktop-niri-xwayland.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.xwayland-satellite ];
    };
}
