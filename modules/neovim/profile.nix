# The editor as installed: every vimzuna aspect but vimtex (vimtex.nix,
# added per host through den.aspects.neovim-tex).
{ vimzuna, ... }:
{
  vimzuna.nvim.includes = with vimzuna; [
    core
    python

    snacks
    navigation
    yazi
    television
    claude
    autopairs

    lsp
    languages
  ];
}
