# Two of ArtCraft's Crafting Apps through nix-craftapps' NixOS module:
# pdfcraft, the default PDF viewer (pdf.nix), and lightcraft, the photo
# library and raw developer (images.nix). Its linkFonts (on by default)
# points /usr/share/fonts at the system fonts: the apps read fonts only there.
{ inputs, ... }:
{
  den.aspects.desktop-craftapps.nixos = {
    imports = [ inputs.nix-craftapps.nixosModules.default ];

    programs.craftapps = {
      enable = true;
      apps.pdfcraft.enable = true;
      apps.lightcraft.enable = true;
    };
  };
}
