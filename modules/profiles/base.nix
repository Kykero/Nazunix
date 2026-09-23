{ den, ... }:
{
  den.aspects.profile-base = {
    includes = [
      den.aspects.nix-settings
      den.aspects.nix-caches
      den.aspects.nix-nh
      den.aspects.keyboard-fr
      den.aspects.neovim
    ];

    nixos =
      { pkgs, ... }:
      {
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
