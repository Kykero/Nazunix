# herdr-projects: a herdr plugin where one coordinator agent hands the work
# out to worker agents, each on its own git worktree (docs/herdr.md). The
# plugin itself is installed through herdr, which fetches a static binary
# into the plugin's folder; its CLI is then linked by hand into
# ~/.local/bin, which is put on PATH here.
{ ... }:
{
  den.aspects.home-herdr-projects.provides.to-users.homeManager = {
    home.sessionPath = [ "$HOME/.local/bin" ];
  };
}
