# Collie: phone web UI (PWA) for the agents running in herdr, served on the
# tailnet through `tailscale serve`. It is remote shell access by design.
# Upstream's flake wraps the release binary (patched for NixOS), so
# `collie update` declines and updates come with lock.yml.
#
# The package's lib/collie is the release tarball root, herdr-plugin.toml
# and a prebuilt bin/collie included, so it is linked as the herdr plugin
# `herdr.collie` as is: its actions (start, stop, url, status, push-keys...)
# run that binary, and Bun is never needed. Everything stateful stays
# imperative (docs/herdr.md): `start` writes the systemd --user unit and
# the serve mapping, and the plugin's config dir
# (`herdr plugin config-dir herdr.collie`) holds the .env with
# COLLIE_TRUSTED_USER, a tailnet login that never enters the repo.
{ inputs, ... }:
{
  den.aspects.home-collie.provides.to-users.homeManager =
    { pkgs, ... }:
    let
      collie = inputs.collie.packages.${pkgs.stdenv.hostPlatform.system}.collie;
    in
    {
      home.packages = [ collie ];

      herdr.plugins."herdr.collie" = "${collie}/lib/collie";
    };
}
