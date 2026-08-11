{ ... }:
{
  den.aspects.yamori-hw.nixos = {
    boot.initrd.systemd.enable = true;

    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = false;
        configurationLimit = 20;
      };
    };

    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
  };
}
