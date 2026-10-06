# Pointer speed for the mouse plugged into the laptop (a Logitech already at
# 2400 DPI, far too fast at libinput's default). The flat profile drops
# acceleration, so accel-speed is a plain multiplier: 1 + speed, here 0.6x.
# The touchpad keeps its own settings. On `dazai` only: `dazai-base` has no
# niri settings module.
{ ... }:
{
  den.aspects.dazai.provides.to-users.homeManager = {
    programs.niri.settings.input.mouse = {
      accel-profile = "flat";
      accel-speed = -0.4;
    };
  };
}
