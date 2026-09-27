# WhatsApp through whatsapp-electron, the Electron wrapper around WhatsApp Web
# packaged in nixpkgs (ISC, no unfree needed). It runs as a native Wayland
# client thanks to NIXOS_OZONE_WL (niri.nix).
{ ... }:
{
  den.aspects.desktop-whatsapp.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.whatsapp-electron ];
    };
}
