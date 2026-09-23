# devenv: per-project development environments declared in devenv.nix
# (languages, services, packages). The binary comes from nixpkgs; projects
# load it on cd through direnv (direnv.nix, `use devenv` in .envrc).
# Its binary caches are accepted because @wheel is a trusted user
# (nix/settings.nix).
{ ... }:
{
  den.aspects.devenv.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.devenv ];
    };
}
