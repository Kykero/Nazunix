{
  den.hosts.x86_64-linux = {
    dazai.users.nazuna = { };    # laptop, 8GB RAM
    yamori.users.nazuna = { };   # desktop, builder

    # install gateway: same machine as dazai, minimal profile.
    # installed first so /etc/nix/nix.conf knows the caches before full pulls niri
    dazai-base = {
      hostName = "dazai";
      profile = "base";
      users.nazuna = { };
    };
  };
}
