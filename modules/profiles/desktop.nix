{ den, ... }:
{
  # the graphical session: niri + Noctalia, one concern per file in modules/desktop/
  den.aspects.profile-desktop = {
    includes = [
      den.aspects.desktop-niri
      den.aspects.desktop-niri-home
      den.aspects.desktop-niri-binds
      den.aspects.desktop-terminal
      den.aspects.desktop-audio
      den.aspects.desktop-noctalia
      den.aspects.desktop-greeter
    ];
  };
}
