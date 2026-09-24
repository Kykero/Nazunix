# Obsidian through home-manager's programs.obsidian, with the `obsidian` CLI.
# Obsidian is unfree: den's unfree battery allows it by name, on both the
# homeManager and the host's nixos side.
{ den, ... }:
{
  den.aspects.desktop-obsidian = {
    includes = [ (den.batteries.unfree [ "obsidian" ]) ];
    provides.to-users.homeManager =
      { ... }:
      {
        programs.obsidian = {
          enable = true;
          cli.enable = true;
        };
      };
  };
}
