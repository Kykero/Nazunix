# PDFs open in pdfcraft (craftapps.nix) from Nautilus and xdg-open. Zathura,
# through home-manager's programs.zathura, stays the viewer of the terminal
# side: Yazi opens PDFs with it (also from Neovim's yazi.nvim), and `O`
# offers the choice between Zathura and pdfcraft. nixpkgs' zathura bundles
# its plugins. xdg.mimeApps.enable is set by browser.nix.
{ ... }:
{
  den.aspects.desktop-pdf.provides.to-users.homeManager = {
    programs.zathura.enable = true;

    xdg.mimeApps.defaultApplications."application/pdf" = "ai.storyteller.pdfcraft.desktop";

    programs.yazi.settings = {
      opener = {
        zathura = [
          {
            run = ''zathura "$@"'';
            orphan = true;
            desc = "Zathura";
            for = "unix";
          }
        ];
        pdfcraft = [
          {
            run = ''pdfcraft "$@"'';
            orphan = true;
            desc = "PdfCraft";
            for = "unix";
          }
        ];
      };
      open.prepend_rules = [
        {
          mime = "application/pdf";
          use = [
            "zathura"
            "pdfcraft"
          ];
        }
      ];
    };
  };
}
