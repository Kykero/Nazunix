# Proton apps. Only Proton Calendar for now: nixpkgs packages no Calendar
# client, so it runs as a web app in a chromeless Chromium window (--app),
# like Outlook (outlook.nix). The Chromium profile is named after Proton,
# not Calendar, so later Proton web apps share the same sign-in.
{ ... }:
{
  den.aspects.desktop-proton.provides.to-users.homeManager =
    { pkgs, lib, ... }:
    let
      proton-calendar = pkgs.writeShellScriptBin "proton-calendar" ''
        exec ${lib.getExe pkgs.chromium} \
          --user-data-dir="''${XDG_DATA_HOME:-$HOME/.local/share}/proton-webapp" \
          --app=https://calendar.proton.me/ "$@"
      '';
    in
    {
      home.packages = [ proton-calendar ];

      # Papirus ships no Proton Calendar logo; the generic calendar icon
      # comes from the active icon theme
      xdg.desktopEntries.proton-calendar = {
        name = "Proton Calendar";
        genericName = "Calendar";
        exec = "proton-calendar";
        icon = "x-office-calendar";
        categories = [
          "Office"
          "Calendar"
        ];
      };
    };
}
