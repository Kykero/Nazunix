{ den, ... }:
{
  den.aspects.profile-full = {
    includes = [
      den.aspects.profile-base
      den.aspects.profile-desktop
    ];
  };
}
