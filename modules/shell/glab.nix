# GitLab CLI. `glab auth login` writes its token to
# ~/.config/glab-cli/config.yml.
{ ... }:
{
  den.aspects.shell-glab.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.glab ];
    };
}
