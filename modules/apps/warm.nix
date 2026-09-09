# den-warm: run once right after a fresh `-base` boot, before the first
# `nh os switch` to the full profile. `nh os build` substitutes the whole
# full-profile closure from the caches nixos-install already burned into
# /etc/nix/nix.conf, without switching -- warms the store so the later
# switch has nothing left to build on an 8GB laptop.
{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.den-warm = pkgs.writeShellApplication {
        name = "den-warm";
        runtimeInputs = [ pkgs.nh ];
        # NH_FLAKE comes from programs.nh.flake (modules/nh.nix); nh's own
        # hostname autodiscovery resolves $(hostname), which already equals
        # the full entity's flake attr because <x>-base.hostName = "<x>"
        # (modules/hosts.nix) -- no -H/flake args needed here.
        text = ''exec nh os build "$@"'';
      };
    };
}
