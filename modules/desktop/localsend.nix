# LocalSend, AirDrop-like file sharing over the LAN. The NixOS module is
# used instead of a bare package: the usual "peers never show up" failure
# on NixOS is the firewall dropping LocalSend's port, and openFirewall
# (on by default, set here explicitly) opens 53317 on both TCP (the
# transfer API) and UDP (multicast discovery).
#
# The nixpkgs build (1.18.0) leaves zlib out of the binary's RUNPATH, so
# it dies at launch on "libz.so.1: cannot open shared object file". The
# package is re-wrapped with zlib on LD_LIBRARY_PATH until that is fixed
# upstream; the desktop entry calls `localsend_app` by name, so it picks
# up the wrapper.
{ ... }:
{
  den.aspects.desktop-localsend.nixos =
    { pkgs, ... }:
    {
      programs.localsend = {
        enable = true;
        openFirewall = true;
        package = pkgs.symlinkJoin {
          name = "localsend-${pkgs.localsend.version}";
          paths = [ pkgs.localsend ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/localsend_app \
              --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ pkgs.zlib ]}
          '';
          inherit (pkgs.localsend) meta;
        };
      };
    };
}
