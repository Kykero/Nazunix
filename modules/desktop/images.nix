# LightCraft (craftapps.nix) opens images from Nautilus and xdg-open: the
# types its desktop entry claims, raw camera files included. GIF, SVG,
# AVIF and HEIC are not among them and keep their previous handler.
{ ... }:
{
  den.aspects.desktop-images.provides.to-users.homeManager =
    let
      types = [
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
    in
    {
      xdg.mimeApps.defaultApplications = builtins.listToAttrs (
        map (type: {
          name = type;
          value = "ai.storyteller.lightcraft.desktop";
        }) types
      );
    };
}
