# LocalSend, AirDrop-like file sharing over the LAN. The NixOS module is
# used instead of a bare package: the usual "peers never show up" failure
# on NixOS is the firewall dropping LocalSend's port, and openFirewall
# (on by default, set here explicitly) opens 53317 on both TCP (the
# transfer API) and UDP (multicast discovery).
{ ... }:
{
  den.aspects.desktop-localsend.nixos.programs.localsend = {
    enable = true;
    openFirewall = true;
  };
}
