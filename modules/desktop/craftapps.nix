# ArtCraft's twelve Crafting Apps (pdfcraft, photocraft, vectorcraft...)
# through nix-craftapps' NixOS module. Its linkFonts (on by default) points
# /usr/share/fonts at the system fonts: the apps read fonts only there.
# pdf.nix makes pdfcraft the default PDF viewer.
{ inputs, ... }:
{
  den.aspects.desktop-craftapps.nixos = {
    imports = [ inputs.nix-craftapps.nixosModules.default ];

    programs.craftapps = {
      enable = true;
      enableAll = true;
    };
  };
}
