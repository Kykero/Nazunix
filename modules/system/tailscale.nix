# Tailscale: WireGuard mesh between the machines of the tailnet. The node is
# joined once by hand with `sudo tailscale up`; the auth state lives in
# /var/lib/tailscale, so no key is kept in the repo.
{ ... }:
{
  den.aspects.tailscale.nixos = {
    services.tailscale = {
      enable = true;
      openFirewall = true; # UDP 41641, direct connections instead of DERP relays
    };
  };
}
