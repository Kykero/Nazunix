# Neovim on every host and profile, built by nvf's NixOS module from the
# vimzuna namespace (namespace.nix). The `vim` class of vimzuna.nvim and
# everything it includes is forwarded into programs.nvf.settings.vim.
{
  den,
  inputs,
  lib,
  vimzuna,
  ...
}:
let
  vimClass =
    { class, aspect-chain }:
    den.batteries.forward {
      each = lib.singleton true;
      fromClass = _: "vim";
      intoClass = _: "nixos";
      intoPath = _: [
        "programs"
        "nvf"
        "settings"
        "vim"
      ];
      fromAspect = _: lib.head aspect-chain;
      adaptArgs = lib.id;
    };
in
{
  den.aspects.neovim = {
    includes = [
      vimClass
      vimzuna.nvim
    ];

    nixos = {
      imports = [ inputs.nvf.nixosModules.default ];
      programs.nvf = {
        enable = true;
        defaultEditor = true;
      };
    };
  };
}
