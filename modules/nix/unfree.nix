# Unfree packages are allowed everywhere, no per-package allowlist.
# home-manager shares this nixpkgs (useGlobalPkgs, defaults.nix).
{ ... }:
{
  den.default.nixos.nixpkgs.config.allowUnfree = true;
}
