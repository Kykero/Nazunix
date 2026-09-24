# Collie: phone web UI (PWA) for the agents running in herdr, served on the
# tailnet through `tailscale serve`. It is remote shell access by design.
# Upstream's flake wraps the release binary (patched for NixOS), so
# `collie update` declines and updates come with lock.yml. Everything
# stateful stays imperative (docs/herdr.md): `collie start` writes the
# systemd --user unit and the serve mapping, and ~/.config/collie/.env
# holds COLLIE_TRUSTED_USER, a tailnet login that never enters the repo.
{ inputs, ... }:
{
  den.aspects.home-collie.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ inputs.collie.packages.${pkgs.stdenv.hostPlatform.system}.collie ];
    };
}
