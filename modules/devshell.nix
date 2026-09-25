# `nix develop`: a debugging and scripting toolbox for working on this flake
# and poking at the running system, kept out of the host closures.
{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          # scripting
          (python3.withPackages (ps: [
            ps.requests
            ps.pyyaml
            ps.rich
          ]))
          jq
          yq-go
          bc

          # nix: format, lint, language server, closure diffs and sizes
          nixfmt
          nil
          statix
          deadnix
          nvd
          nix-tree
          nix-diff

          # processes, syscalls, memory
          strace
          perf
          ltrace
          gdb
          lsof
          psmisc
          htop

          # files and search
          ripgrep
          fd
          file
          tree
          ncdu

          # hardware and network
          pciutils
          usbutils
          lshw
          dnsutils
          curl
          wget
        ];
      };
    };
}
