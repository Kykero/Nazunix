{ den, ... }:
{
  # shared hardware aspect for the desktop.
  # disko.nix, boot.nix (and later hardware.nix) all write into yamori-hw.
  # no zram here: 32GB RAM, kernel defaults are fine
  den.aspects.yamori.includes = [ den.aspects.yamori-hw ];
  den.aspects.yamori-base.includes = [ den.aspects.yamori-hw ];
}
