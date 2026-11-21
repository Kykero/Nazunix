# OpenVPN client through NetworkManager, for the work VPN. Only the plugin is
# declared here: the profile (.ovpn with its embedded key) is imported once by
# hand with `nmcli connection import type openvpn file <profile>.ovpn`, so no
# server address or key is kept in the repo. Set `ipv4.never-default yes` on
# the imported connection so only the work subnets go through the tunnel and
# Tailscale keeps its direct paths.
{ ... }:
{
  den.aspects.openvpn.nixos =
    { pkgs, ... }:
    {
      networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
    };
}
