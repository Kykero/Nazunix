# Windows 11 dual boot (dazai: Excel with VBA for work; yamori: Windows on
# its own SATA disk). An explicit GRUB entry instead of os-prober: no scan
# at every rebuild, and Windows' ESP is found by the file it holds, on
# whichever disk it sits, so no UUID lands in the repo.
{ ... }:
{
  den.aspects.windows-dualboot.nixos = {
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
