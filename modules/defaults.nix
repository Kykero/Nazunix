{ inputs, lib, ... }:
{
  imports = [ inputs.den.flakeModule ];

  den.default.nixos.system.stateVersion = "25.11";
  den.default.homeManager.home.stateVersion = "25.11";

  # home-manager as a NixOS module for every user
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.default.includes = [ den.batteries.hostname ];
}
