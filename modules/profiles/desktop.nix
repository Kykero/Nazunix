{ den, ... }:
{
  # the graphical session: niri + Noctalia, one concern per file in modules/desktop/
  den.aspects.profile-desktop = {
    includes = [
      den.aspects.desktop-niri
      den.aspects.desktop-niri-home
      den.aspects.desktop-niri-binds
      den.aspects.desktop-niri-window-rules
      den.aspects.desktop-niri-blur
      den.aspects.desktop-terminal
      den.aspects.desktop-browser
      den.aspects.desktop-mail
      den.aspects.desktop-audio
      den.aspects.desktop-power
      den.aspects.desktop-bluetooth
      den.aspects.desktop-noctalia
      den.aspects.desktop-greeter
      den.aspects.desktop-vm
    ];
  };
}
