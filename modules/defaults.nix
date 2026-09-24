{ inputs, den, lib, ... }:
{
  imports = [ inputs.den.flakeModule ];

  den.default.nixos.system.stateVersion = "25.11";
  den.default.homeManager.home.stateVersion = "25.11";

  # home-manager as a NixOS module for every user
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
  # users evaluate against the host's nixpkgs (config, overlays), no second instance
  den.default.nixos.home-manager.useGlobalPkgs = true;

  den.default.includes = [ den.batteries.hostname ];
}
