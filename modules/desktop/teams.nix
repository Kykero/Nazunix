# Microsoft Teams through teams-for-linux, the Electron wrapper around the
# Teams web app packaged in nixpkgs (GPL, no unfree needed). It runs as a
# native Wayland client thanks to NIXOS_OZONE_WL (niri.nix), with PipeWire
# screen sharing through the gnome portal.
{ ... }:
{
  den.aspects.desktop-teams.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.teams-for-linux ];
    };
}
