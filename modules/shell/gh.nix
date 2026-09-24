# GitHub CLI. `gh auth login` keeps its token in the Secret Service
# (gnome-keyring) when a session provides one, in hosts.yml otherwise.
{ ... }:
{
  den.aspects.shell-gh.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.gh ];
    };
}
