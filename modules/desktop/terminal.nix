# terminal emulator for the desktop, spawned by Mod+T (niri-binds.nix)
{ ... }:
{
  den.aspects.desktop-terminal.provides.to-users.homeManager = {
    programs.alacritty.enable = true;
  };
}
