# PipeWire: not enabled by niri-flake, and Noctalia refuses to start without
# a running daemon (WirePlumber >= 0.5 is on by default).
{ ... }:
{
  den.aspects.desktop-audio.nixos = {
    # realtime scheduling for the user pipewire services; the pipewire module
    # only grants it to the @pipewire group, which no desktop user joins
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
}
