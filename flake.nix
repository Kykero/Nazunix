{
  description = "Nazunix - NixOs Configuration based on Den Framework";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    import-tree.url = "github:vic/import-tree";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    den.url = "github:denful/den";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ── coming later, kept here so this file never needs rethinking ──
    # sops-nix = { url = "github:Mic92/sops-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    disko    = { url = "github:nix-community/disko"; inputs.nixpkgs.follows = "nixpkgs"; };
    # niri.url = "github:sodiboo/niri-flake";   # NO follows -- keeps niri.cachix.org
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ (inputs.import-tree ./modules) ];
    };
}
