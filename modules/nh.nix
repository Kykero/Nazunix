{ den, ... }:
{
  # flake level: nh-wrapped apps, `nix run .#<host>` from any nix-enabled machine
  perSystem =
    { pkgs, ... }:
    {
      packages = den.lib.nh.denPackages { fromFlake = true; } pkgs;
    };

  # host level: nh on the machines themselves, with automatic gc
  den.aspects.nix-nh.nixos = {
    programs.nh = {
      enable = true;
      flake = "/home/nazuna/Nazunix";
      clean = {
        enable = true;
        dates = "Sat 13:00";
        extraArgs = "--keep-since 14d --keep 3";
      };
    };
  };
}
