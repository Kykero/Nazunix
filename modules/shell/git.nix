# git system-wide: flakes fetch through it and root needs it too (nh,
# rebuild.nix). Every user also gets home-manager's git with the GitHub
# identity, through the noreply address so no real email reaches a commit.
{ ... }:
{
  den.aspects.shell-git = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.git ];
      };

    provides.to-users.homeManager = {
      programs.git = {
        enable = true;
        settings.user = {
          name = "Kykero";
          email = "129735572+Kykero@users.noreply.github.com";
        };
      };
    };
  };
}
