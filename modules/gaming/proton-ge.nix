# GE-Proton as an extra Steam compatibility tool. Unlike Proton Experimental
# it ships Wine's Wayland driver, turned on per game with
# `PROTON_ENABLE_WAYLAND=1 %command%`. Under Xwayland, Wine derives its key
# mapping from the first xkb group (fr) and ignores Alt+Shift; the Wayland
# driver follows the layout niri is on.
{ ... }:
{
  den.aspects.gaming.provides.proton-ge.nixos =
    { pkgs, ... }:
    {
      programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
}
