# System-wide fonts for the desktop. JetBrains Mono with the Nerd Font
# glyphs (icons, powerline symbols) is the terminal font (terminal.nix);
# fontconfig names the family "JetBrainsMono Nerd Font".
{ ... }:
{
  den.aspects.desktop-fonts.nixos =
    { pkgs, ... }:
    {
      fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
    };
}
