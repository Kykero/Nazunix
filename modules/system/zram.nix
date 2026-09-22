{ ... }:
{
  den.aspects.zram.nixos = {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };

    boot.kernel.sysctl = {
      "vm.swappiness" = 150; # zram is the only swap, use it eagerly
      "vm.page-cluster" = 0;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
    };

    # never build in RAM on a 8GB machine
    boot.tmp.useTmpfs = false;
  };
}
