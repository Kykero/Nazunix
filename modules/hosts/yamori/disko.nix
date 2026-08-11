{ inputs, ... }:
{
  den.aspects.yamori-hw.nixos = {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/nvme0n1"; # TODO: confirm with `lsblk` from the live ISO
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [
                "-L"
                "yamori"
                "-f"
              ];
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd:1"
                    "noatime"
                  ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd:1"
                    "noatime"
                  ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd:1"
                    "noatime"
                  ];
                };
                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = [
                    "compress=zstd:1"
                    "noatime"
                  ];
                };
                "@swap" = {
                  mountpoint = "/.swapvol";
                  mountOptions = [ "noatime" ]; # never compress a swapfile
                  swap.swapfile.size = "8G"; # OOM safety net for big builds
                };
              };
            };
          };
        };
      };
    };

    # journald must be writable before switch-root
    fileSystems."/var/log".neededForBoot = true;
  };
}
