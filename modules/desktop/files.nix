# Nautilus, the file manager. xdg-desktop-portal-gnome (registered by
# programs.niri) uses it for the file chooser dialog, so apps asking the
# portal to open or save a file need it too. gvfs gives it the trash,
# MTP phones and network mounts. It is also the default for folders.
#
# Riced like the terminal: the window background is translucent (0.85, as
# ghostty) and every pane above it is cleared, so niri's blur
# (niri-blur.nix) shows through once and not stacked. Colours stay
# Noctalia's (@window_bg_color comes from noctalia.css). Scoped to
# .nautilus-window, Nautilus' own style class; gtk.css from gtk-theme.nix
# imports this sheet.
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

      xdg.configFile."gtk-4.0/nautilus.css".text = ''
        window.nautilus-window {
          background-color: alpha(@window_bg_color, 0.85);
        }

        .nautilus-window toolbarview,
        .nautilus-window headerbar,
        .nautilus-window .content-pane,
        .nautilus-window .view,
        .nautilus-window scrolledwindow,
        .nautilus-window gridview,
        .nautilus-window columnview,
        .nautilus-window listview {
          background-color: transparent;
          background-image: none;
          box-shadow: none;
        }

        /* the sidebar stays a shade apart, as in stock Nautilus */
        .nautilus-window .sidebar-pane,
        .nautilus-window .navigation-sidebar {
          background-color: alpha(@sidebar_bg_color, 0.35);
        }
      '';
    };
  };
}
