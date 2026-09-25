# Zathura, the PDF viewer, through home-manager's programs.zathura. nixpkgs'
# zathura bundles its plugins; PDFs go to the mupdf one, whose desktop entry
# is the one that claims application/pdf. xdg.mimeApps.enable is set by
# browser.nix.
{ ... }:
{
  den.aspects.desktop-pdf.provides.to-users.homeManager = {
    programs.zathura.enable = true;

    xdg.mimeApps.defaultApplications."application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
  };
}
