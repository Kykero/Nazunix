# Moonlight: the client side of game streaming, to play from another
# Sunshine (or GeForce Experience) host. Outgoing connections only, so no
# firewall change.
{ ... }:
{
  den.aspects.gaming.provides.moonlight.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.moonlight-qt ];
    };
}
