# pwvucontrol, a native PipeWire volume mixer: per-device and per-app levels,
# input gain (the USB mic) and default device choice, beyond what Noctalia's
# volume widget exposes.
{ ... }:
{
  den.aspects.desktop-audio-mixer.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.pwvucontrol ];
    };
}
