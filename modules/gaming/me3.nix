# me3 (Mod Engine 3): mod loader for FromSoftware games under Proton.
# Profiles live in ~/.config/me3/profiles; `me3 launch -p <profile> -g <game>`.
# The launcher entry starts Nightreign with the mmv-weapons profile; the
# unmodded game is still launched from Steam. me3 needs an explicit Proton
# version forced on the game in Steam (Properties > Compatibility).
{ ... }:
{
  den.aspects.gaming.provides.me3.provides.to-users.homeManager =
    { pkgs, lib, ... }:
    {
      home.packages = [ pkgs.me3 ];

      xdg.desktopEntries.nightreign-modded = {
        name = "ELDEN RING NIGHTREIGN (modded)";
        comment = "Nightreign with the mmv-weapons me3 profile";
        exec = "${lib.getExe' pkgs.me3 "me3"} launch -p mmv-weapons -g nightreign";
        # Icon installed by Steam's own desktop shortcut for the game.
        icon = "steam_icon_2622380";
        categories = [ "Game" ];
        terminal = false;
      };
    };
}
