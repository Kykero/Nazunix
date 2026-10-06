# Outlook as a web app: nixpkgs packages no Outlook wrapper (unlike Teams and
# WhatsApp), so Outlook on the web runs in a chromeless Chromium window
# (--app) with its own profile, isolated from the main browser. Chromium runs
# as a native Wayland client thanks to NIXOS_OZONE_WL (niri.nix).
{ ... }:
{
  den.aspects.desktop-outlook.provides.to-users.homeManager =
    { pkgs, lib, ... }:
    let
      outlook = pkgs.writeShellScriptBin "outlook" ''
        exec ${lib.getExe pkgs.chromium} \
          --user-data-dir="''${XDG_DATA_HOME:-$HOME/.local/share}/outlook-webapp" \
          --app=https://outlook.office.com/mail/ "$@"
      '';
    in
    {
      home.packages = [ outlook ];

      xdg.desktopEntries.outlook = {
        name = "Outlook";
        genericName = "Mail";
        exec = "outlook";
        icon = "internet-mail";
        categories = [
          "Network"
          "Email"
        ];
      };
    };
}
