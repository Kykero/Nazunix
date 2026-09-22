# mail client for the desktop: Aerion (Go + Wails, direct IMAP/SMTP).
# withOAuth ships the aerion-creds shim, without which Gmail and Microsoft
# accounts cannot sign in; nixpkgs leaves it off by default.
{ ... }:
{
  den.aspects.desktop-mail.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ (pkgs.aerion.override { withOAuth = true; }) ];
    };
}
