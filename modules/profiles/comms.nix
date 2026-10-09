{ den, ... }:
{
  # mail, messaging, chat and meeting apps, pulled in by the desktop profile
  den.aspects.profile-comms = {
    includes = [
      den.aspects.desktop-mail
      den.aspects.desktop-outlook
      den.aspects.desktop-teams
      den.aspects.desktop-whatsapp
      den.aspects.desktop-discord
    ];
  };
}
