# Loupe (GNOME Image Viewer), a GTK4/libadwaita app like Nautilus, opens
# images from Nautilus and xdg-open.
{ ... }:
{
  den.aspects.desktop-images.provides.to-users.homeManager =
    { pkgs, ... }:
    let
      types = [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/webp"
        "image/bmp"
        "image/tiff"
        "image/svg+xml"
        "image/avif"
        "image/heic"
        "image/jxl"
        "image/x-icon"
      ];
    in
    {
      home.packages = [ pkgs.loupe ];

      xdg.mimeApps.defaultApplications = builtins.listToAttrs (
        map (type: {
          name = type;
          value = "org.gnome.Loupe.desktop";
        }) types
      );
    };
}
