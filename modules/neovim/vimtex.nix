# VimTeX + texlive-full + zathura SyncTeX. Not part of vimzuna.nvim
# (texlive-full is several GB): `neovim-tex` forwards it into nvf on the
# hosts that include it (yamori only, modules/hosts/yamori/yamori.nix).
{ vimzuna, vimzunaForward, ... }:
{
  den.aspects.neovim-tex.includes = [
    vimzunaForward
    vimzuna.vimtex
  ];

  vimzuna.vimtex.vim =
    { pkgs, ... }:
    {
      extraPackages = with pkgs; [
        texliveFull # TeX distribution + latexmk
        zathura # PDF viewer with SyncTeX
        xdotool # needed by zathura SyncTeX backward search
      ];

      # VimTeX is an old VimScript plugin: it must be available at startup,
      # not lazy-managed via extraPlugins.
      startPlugins = [ pkgs.vimPlugins.vimtex ];

      globals = {
        vimtex_view_method = "zathura";
        vimtex_compiler_method = "latexmk";
        vimtex_quickfix_open_on_warning = 0;
      };
    };
}
