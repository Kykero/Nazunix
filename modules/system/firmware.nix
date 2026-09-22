# linux-firmware (GPU DMC, WiFi, ...): without it s2idle never reaches its
# low-power state and a suspended laptop keeps draining. hardware.nix
# (not-detected.nix) sets this as mkDefault; dazai has no hardware.nix in
# the repo yet, so set it here. Same value, no conflict once it lands.
{ ... }:
{
  den.aspects.firmware.nixos.hardware.enableRedistributableFirmware = true;
}
