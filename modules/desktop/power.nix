# Noctalia reads the battery through UPower and switches power profiles
# through org.freedesktop.UPower.PowerProfiles (power-profiles-daemon).
# PPD, not TLP: NixOS refuses both at once, and Noctalia only talks to PPD.
{ ... }:
{
  den.aspects.desktop-power.nixos = {
    services.upower = {
      enable = true;
      # the default HybridSleep needs hibernate, impossible with zram-only swap
      criticalPowerAction = "PowerOff";
    };
    services.power-profiles-daemon.enable = true;
  };
}
