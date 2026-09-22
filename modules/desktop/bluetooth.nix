# BlueZ: Noctalia's bluetooth widget and panel talk to org.bluez over D-Bus.
{ ... }:
{
  den.aspects.desktop-bluetooth.nixos = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
