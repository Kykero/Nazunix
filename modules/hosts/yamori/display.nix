# The desktop's main screen is the Samsung 1440p panel on DP-1; the Kamvas
# pen display on HDMI-A-1 is secondary. niri would otherwise focus the first
# output by name (HDMI-A-1) at startup and open the named workspaces there.
# On `yamori` only: `yamori-base` has no niri settings module.
{ ... }:
{
  den.aspects.yamori.provides.to-users.homeManager = {
    programs.niri.settings = {
      outputs."DP-1".focus-at-startup = true;
      workspaces = {
        "1".open-on-output = "DP-1";
        "2".open-on-output = "DP-1";
      };
    };
  };
}
