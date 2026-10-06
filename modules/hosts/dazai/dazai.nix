{ den, ... }:
{
  # shared hardware aspect: everything physical about the laptop.
  # disko.nix (and later hardware.nix) write into dazai-hw.
  den.aspects.dazai-hw.includes = [
    den.aspects.boot-grub-efi
    den.aspects.zram
    den.aspects.laptop-power
    den.aspects.windows-dualboot
  ];

  # both entities run on this machine
  den.aspects.dazai.includes = [
    den.aspects.dazai-hw
    den.aspects.gaming._.steam # 8GB RAM: Steam only, no Wine/Prism
  ];
  den.aspects.dazai-base.includes = [ den.aspects.dazai-hw ];
}
