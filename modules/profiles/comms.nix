{ den, ... }:
{
  # messaging and meeting apps, pulled in by the desktop profile
  den.aspects.profile-comms = {
    includes = [
      den.aspects.desktop-teams
      den.aspects.desktop-whatsapp
    ];
  };
}
