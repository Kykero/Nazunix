{ den, ... }:
{
  # every host automatically includes the aspect matching its profile
  den.schema.host.includes = [ ({ host }: den.aspects."profile-${host.profile}") ];
}
