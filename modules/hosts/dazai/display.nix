# The laptop's 13" 1080p panel: niri's automatic scale (from the panel's
# DPI) makes everything too large. 1.2 is exact for 1920x1080 (a 1600x900
# logical screen, 144/120 in the fractional-scale protocol), so niri keeps
# it as is. On `dazai` only: `dazai-base` has no niri settings module.
{ ... }:
{
  den.aspects.dazai.provides.to-users.homeManager = {
    programs.niri.settings.outputs."eDP-1".scale = 1.2;
  };
}
