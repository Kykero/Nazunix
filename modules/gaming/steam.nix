# Steam at the NixOS level: the module turns on 32-bit graphics, the
# controller udev rules and the Remote Play firewall ports that a plain
# home.packages entry would miss. Unfree is already allowed (nix/unfree.nix).
{ ... }:
{
  den.aspects.gaming.provides.steam.nixos.programs.steam.enable = true;
}
