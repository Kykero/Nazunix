{ den, ... }:
{
  # TODO(phase 4): delete this file -- replaced by real disko + hardware config
  den.aspects.fake-hw.nixos = {
    boot.loader.grub.enable = false;
    fileSystems."/".device = "/dev/fake";
    fileSystems."/".fsType = "auto";
  };

  den.aspects.dazai.includes      = [ den.aspects.fake-hw ];
  den.aspects.dazai-base.includes = [ den.aspects.fake-hw ];
  den.aspects.yamori.includes     = [ den.aspects.fake-hw ];
}
