# Discord through the official client packaged in nixpkgs (unfree, allowed
# in unfree.nix). The nixpkgs wrapper turns on Wayland when NIXOS_OZONE_WL
# is set (niri.nix).
{ ... }:
{
  den.aspects.desktop-discord.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.discord ];
    };
}
