{ den, ... }:
{
  # TODO(phase 4, commit C): delete this file -- yamori gets real hardware
  den.aspects.fake-hw.nixos = {
    boot.loader.grub.enable = false;
    fileSystems."/".device = "/dev/fake";
    fileSystems."/".fsType = "auto";
  };

  den.aspects.yamori.includes = [ den.aspects.fake-hw ];
}
