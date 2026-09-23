# GTK apps follow Noctalia's colours. Noctalia's GTK template (enabled in its
# GUI: Settings > Theming > Templates > GTK) writes gtk-{3,4}.0/noctalia.css
# and runs apply.sh, which imports it into gtk.css and sets adw-gtk3(-dark)
# and the color-scheme through gsettings.
#
# gtk-4.0/gtk.css is owned here so other aspects can add their own sheet
# (nautilus.css from files.nix). apply.sh leaves a gtk.css alone once it
# already imports noctalia.css, so the read-only store link is never
# replaced. A missing imported file is only a warning in GTK. gtk-3.0 stays
# fully to apply.sh.
{ ... }:
{
  den.aspects.desktop-gtk-theme = {
    nixos =
      { pkgs, ... }:
      {
        # apply.sh switches GTK3 apps to these themes when it finds them
        environment.systemPackages = [ pkgs.adw-gtk3 ];
        # gsettings needs the dconf service to store color-scheme
        programs.dconf.enable = true;
      };

    provides.to-users.homeManager = {
      xdg.configFile."gtk-4.0/gtk.css".text = ''
        @import url("noctalia.css");
        @import url("nautilus.css");
      '';
    };
  };
}
