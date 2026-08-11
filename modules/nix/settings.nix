{ inputs, ... }:
{
  den.aspects.nix-settings.nixos = {
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];
        warn-dirty = false;
      };

      # the system's nixpkgs is the flake's nixpkgs, no ghost channel
      channel.enable = false;
      registry.nixpkgs.flake = inputs.nixpkgs;
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      optimise = {
        automatic = true;
        dates = [ "Sat 14:00" ];
        persistent = true;
      };
    };
  };
}
