{ ... }:
{
  den.aspects.boot-grub-efi.nixos = {
    # systemd in the initrd: clean boot flow, prerequisite for TPM2 unlock later
    boot.initrd.systemd.enable = true;

    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev"; # EFI only, no MBR install
        useOSProber = false; # NixOS is alone on these machines
        configurationLimit = 20; # keep the menu readable
      };
    };

    # btrfs self-healing: monthly checksum verification
    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
  };
}
