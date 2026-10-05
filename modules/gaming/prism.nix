# Prism Launcher: Minecraft instances and mod packs.
{ ... }:
{
  den.aspects.gaming.provides.prism.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.prismlauncher ];
    };
}
