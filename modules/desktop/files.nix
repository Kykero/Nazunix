# Nautilus, the file manager. xdg-desktop-portal-gnome (registered by
# programs.niri) uses it for the file chooser dialog, so apps asking the
# portal to open or save a file need it too. gvfs gives it the trash,
# MTP phones and network mounts. It is also the default for folders.
{ ... }:
{
  den.aspects.desktop-files = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.nautilus ];
        services.gvfs.enable = true;
      };

    provides.to-users.homeManager = {
      xdg.mimeApps.defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";
    };
  };
}
