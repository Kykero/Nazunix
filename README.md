# Nazunix

Declarative NixOS for a small personal fleet (`yamori` desktop, `dazai`
laptop, user `nazuna`), built on flake-parts, import-tree and the den
framework. Desktop: niri + Noctalia, AZERTY; ghostty, fish and Zen Browser
for every user.

The repo is the installer: `den-bootstrap` runs from a NixOS live USB, wipes
the chosen disk, installs the `-base` gateway and then the full profile.

## Documentation

- [Installing from a USB stick](docs/install.md): preparing the stick and the
  keys directory, `den-bootstrap`, first boot, day-2 rebuilds
- [Day-2 rebuilds](docs/den-rebuild.md): what `den-rebuild` does, its
  arguments and failure modes
- [Iterating in a VM](docs/vm.md): `nix run .#vm-<host>`, the rebuild and
  relaunch loop, live niri tweaks, resetting the disk image
- [Keyboard (AZERTY) in niri](docs/keyboard.md): transposed binds and the
  Noctalia shortcuts
- [Roadmap](docs/ROADMAP.md): architecture and phase status
