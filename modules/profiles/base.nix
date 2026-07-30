{ den, ... }:
{
  den.aspects.profile-base = {
    includes = with den.aspects [ nix-caches ];

    nixos =
      { pkgs, ... }:
      {
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        environment.systemPackages = with pkgs; [
          git
          vim
          btop
        ];

        services.openssh.enable = true;
        networking.networkmanager.enable = true;
      };
  };
}
