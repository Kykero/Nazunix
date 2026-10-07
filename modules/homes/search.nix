# fd (files) and ripgrep (text): the sources of television's files and
# text channels, and the everyday search tools in the shell.
{ ... }:
{
  den.aspects.home-search.provides.to-users.homeManager.programs = {
    fd.enable = true;
    ripgrep.enable = true;
  };
}
