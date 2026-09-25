# Two named workspaces that exist from session start. Unlike niri's dynamic
# workspaces, named ones persist when their last window closes; the usual
# empty dynamic workspace still follows them. niri-flake creates them in
# key order, the key doubling as the name.
{ ... }:
{
  den.aspects.desktop-niri-workspaces.provides.to-users.homeManager = {
    programs.niri.settings.workspaces = {
      "1" = { };
      "2" = { };
    };
  };
}
