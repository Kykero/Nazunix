# Images open from Nautilus and xdg-open in gThumb: the arrow keys walk
# through the folder's pictures, and it crops, rotates and flips in place.
# gThumb's viewer moves between files with Page_Up/Page_Down and scrolls
# with the arrows; shortcuts.xml, read after the extensions register their
# shortcuts, swaps that so Left/Right walk the folder. Only the listed
# actions change. The file is read-only, so the shortcuts page of gThumb's
# preferences cannot save over it.
# LightCraft (craftapps.nix) comes second for the types its desktop entry
# claims, and takes the raw camera files gThumb's entry does not.
{ ... }:
{
  den.aspects.desktop-images.provides.to-users.homeManager =
    { lib, pkgs, ... }:
    let
      gthumb = [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/webp"
        "image/bmp"
        "image/tiff"
        "image/svg+xml"
        "image/jxl"
        "image/x-tga"
        "image/x-ico"
      ];
      lightcraft = [
        "image/png"
        "image/jpeg"
        "image/tiff"
        "image/webp"
        "image/x-adobe-dng"
        "image/x-sony-arw"
        "image/x-canon-cr2"
        "image/x-canon-cr3"
        "image/x-nikon-nef"
        "image/x-fuji-raf"
        "image/x-olympus-orf"
        "image/x-panasonic-rw2"
        "image/x-pentax-pef"
      ];
      handlers =
        type:
        lib.optional (lib.elem type gthumb) "org.gnome.gThumb.desktop"
        ++ lib.optional (lib.elem type lightcraft) "ai.storyteller.lightcraft.desktop";
    in
    {
      home.packages = [ pkgs.gthumb ];

      xdg.configFile."gthumb/shortcuts.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <shortcuts>
          <shortcut action="show-previous-image" accelerator="Left"/>
          <shortcut action="show-next-image" accelerator="Right"/>
          <shortcut action="scroll-step-left" accelerator=""/>
          <shortcut action="scroll-step-right" accelerator=""/>
        </shortcuts>
      '';

      xdg.mimeApps.defaultApplications = lib.genAttrs (lib.unique (gthumb ++ lightcraft)) handlers;
    };
}
