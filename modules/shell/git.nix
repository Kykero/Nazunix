# git system-wide: flakes fetch through it and root needs it too (nh,
# rebuild.nix). The identity is not declared here: bootstrap.nix writes it
# from git.env, which stays off the repo.
{ ... }:
{
  den.aspects.shell-git.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.git ];
    };
}
