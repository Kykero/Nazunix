# Windows 11 dual boot on the laptop (Excel with VBA for work). Windows sits
# in the space after the NixOS partition (disko.nix) and shares the ESP.
# An explicit GRUB entry instead of os-prober: no scan at every rebuild, and
# the ESP is found by the file it holds, so no UUID lands in the repo.
{ ... }:
{
  den.aspects.dazai-hw.nixos = {
    boot.loader.grub.extraEntries = ''
      menuentry "Windows 11" {
        insmod part_gpt
        insmod fat
        insmod chain
        search --no-floppy --file --set=root /EFI/Microsoft/Boot/bootmgfw.efi
        chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      }
    '';

    # Windows keeps the hardware clock in local time; NixOS follows it so
    # the clock is not off by an hour or two after switching systems
    time.hardwareClockInLocalTime = true;
  };
}
