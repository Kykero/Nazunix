# Unfree packages are allowed everywhere, no per-package allowlist.
# home-manager evaluates its own nixpkgs (no useGlobalPkgs), so both
# classes need the flag.
{ ... }:
{
  den.default.nixos.nixpkgs.config.allowUnfree = true;
  den.default.homeManager.nixpkgs.config.allowUnfree = true;
}
