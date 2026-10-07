# VimTeX + texlive-full + zathura SyncTeX. Not part of vimzuna.nvim
# (texlive-full is several GB): add it to profile.nix's includes to get it.
{ ... }:
{
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
