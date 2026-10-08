# direnv loads a directory's environment on cd (.envrc: `use devenv`,
# `use flake`). nix-direnv caches the evaluated environment and keeps it
# from being garbage-collected. home-manager hooks it into fish by itself.
{ ... }:
{
  den.aspects.direnv.provides.to-users.homeManager = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
  };
}
