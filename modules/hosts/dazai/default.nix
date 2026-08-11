{ den, ... }:
{
  # shared hardware aspect: everything physical about the laptop.
  # disko.nix, boot.nix (and later hardware.nix) all write into dazai-hw.
  den.aspects.dazai-hw.includes = [ den.aspects.zram ];

  # both entities run on this machine
  den.aspects.dazai.includes = [ den.aspects.dazai-hw ];
  den.aspects.dazai-base.includes = [ den.aspects.dazai-hw ];
}
