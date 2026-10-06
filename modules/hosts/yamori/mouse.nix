# Pointer speed for the desktop's mouse (a Logitech already at 2400 DPI,
# far too fast at libinput's default). The flat profile drops acceleration,
# so accel-speed is a plain multiplier: 1 + speed, here 0.5x (~1200 DPI).
# On `yamori` only: `yamori-base` has no niri settings module.
{ ... }:
{
  den.aspects.yamori.provides.to-users.homeManager = {
    programs.niri.settings.input.mouse = {
      accel-profile = "flat";
      accel-speed = -0.5;
    };
  };
}
