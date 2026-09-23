{ den, ... }:
{
  den.aspects.nazuna = {
    includes = [
      # account creation + wheel/networkmanager membership
      den.batteries.define-user
      den.batteries.primary-user

      # home environment; the login shell (fish) is every user's default,
      # from modules/homes/fish.nix. bash stays for scripts and recovery.
      den.aspects.home-bash
      den.aspects.home-btop

      # coding agents, on the -base gateways too (from the numtide cache)
      den.aspects.home-claude-code
      den.aspects.home-codex
      den.aspects.home-herdr
    ];
  };
}
