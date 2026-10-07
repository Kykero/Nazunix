# Vimzuna, the Neovim configuration: a local den namespace (module argument
# `vimzuna`) holding one aspect per editor concern, each written in a `vim`
# class, i.e. nvf's `config.vim`. Kept apart from den.aspects so its short
# names (core, lsp, yazi...) never collide with the system's aspects.
# neovim.nix forwards the `vim` class into NixOS' programs.nvf.
{ inputs, ... }:
{
  imports = [ (inputs.den.namespace "vimzuna" false) ];
}
