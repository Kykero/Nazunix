# Images open from Nautilus and xdg-open in swayimg, a light Wayland-native
# viewer that covers the common formats (GIF, SVG, AVIF, HEIC and JXL
# included). LightCraft (craftapps.nix) comes second for the types its
# desktop entry claims, raw camera files included, and takes the raw files
# swayimg cannot read.
{ ... }:
{
  den.aspects.desktop-images.provides.to-users.homeManager =
    { lib, pkgs, ... }:
    let
      swayimg = [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/webp"
        "image/bmp"
        "image/tiff"
        "image/svg+xml"
        "image/avif"
        "image/heif"
        "image/jxl"
        "image/x-tga"
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
        lib.optional (lib.elem type swayimg) "swayimg.desktop"
        ++ lib.optional (lib.elem type lightcraft) "ai.storyteller.lightcraft.desktop";
    in
    {
      home.packages = [ pkgs.swayimg ];

      xdg.mimeApps.defaultApplications = lib.genAttrs (lib.unique (swayimg ++ lightcraft)) handlers;
    };
}
