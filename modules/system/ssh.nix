# OpenSSH server, key-only: every machine of the fleet accepts the user key
# of every other one, passwords are refused. Machines reach each other by
# name through Tailscale MagicDNS (`ssh nazuna@yamori`), so no address is
# kept here. A new machine adds its `~/.ssh/id_ed25519.pub` to the list.
{ ... }:
{
  den.aspects.ssh.nixos = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    users.users.nazuna.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8kY0/CoFNGEJJu7T/iW7/cqCr/1UCsmp8fA/tuhjZ/ dazai"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG7zTVS3hxq1Gt8mLwlte6a2PMDPhrRO4Hls/Lpo4uoK yamori"
    ];
  };
}
