{ den, ... }:
{
  # every GRUB machine gets the same theme
  den.aspects.boot-grub-efi.includes = [ den.aspects.grub-theme ];

  den.aspects.boot-grub-efi.nixos = {
    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev"; # EFI only, no MBR install
        useOSProber = false; # other systems get an explicit entry (windows-dualboot.nix)
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
