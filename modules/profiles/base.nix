{ den, ... }:
{
  den.aspects.profile-base = {
    includes = [
      den.aspects.nix-settings
      den.aspects.nix-caches
      den.aspects.nix-nh
      den.aspects.keyboard-fr
      den.aspects.neovim
      den.aspects.devenv
      den.aspects.direnv
      den.aspects.tailscale
      den.aspects.shell-git
      den.aspects.shell-gh
      den.aspects.shell-glab
    ];

    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          vim
          btop
        ];

        services.openssh.enable = true;
        networking.networkmanager.enable = true;
      };
  };
}
