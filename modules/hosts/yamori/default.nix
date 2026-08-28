{ den, ... }:
{
  # shared hardware aspect for the desktop.
  # disko.nix (and later hardware.nix) write into yamori-hw.
  # no zram here: 32GB RAM, kernel defaults are fine
  den.aspects.yamori-hw.includes = [ den.aspects.boot-grub-efi ];

  den.aspects.yamori.includes = [ den.aspects.yamori-hw ];
  den.aspects.yamori-base.includes = [ den.aspects.yamori-hw ];
}
