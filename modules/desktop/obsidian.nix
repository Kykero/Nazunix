# Obsidian through home-manager's programs.obsidian, with the `obsidian` CLI.
# Unfree, covered by the global allowUnfree (modules/nix/unfree.nix).
{ ... }:
{
  den.aspects.desktop-obsidian.provides.to-users.homeManager =
    { ... }:
    {
      programs.obsidian = {
        enable = true;
        cli.enable = true;
      };
    };
}
