# Images open from Nautilus and xdg-open in gThumb: the arrow keys walk
# through the folder's pictures, and it crops, rotates and flips in place.
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

      xdg.mimeApps.defaultApplications = lib.genAttrs (lib.unique (gthumb ++ lightcraft)) handlers;
    };
}
