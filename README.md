# Nazunix

Declarative NixOS for a small personal fleet (`yamori` desktop, `dazai`
laptop, user `nazuna`), built on flake-parts, import-tree and the den
framework. Desktop: niri + Noctalia, AZERTY + US (Alt+Shift); ghostty, fish
and Zen Browser for every user. Each machine also has a `-base` twin, the
install gateway, booted first with only the base profile.

This file is an entry point: each folder under `modules/` has its own README,
and the procedures live in [`docs/`](docs/).

## Install

The repo is the installer: `den-bootstrap` runs from a NixOS live USB. Follow
[docs/install.md](docs/install.md).

## Day 2

- [docs/den-rebuild.md](docs/den-rebuild.md): updating an installed machine
  with `den-rebuild`
- [docs/vm.md](docs/vm.md): trying changes in a VM with `nix run .#vm-<host>`

## What a machine gets

Every host runs the `full` profile (base + desktop + AI); its `-base` twin
runs only `base`. The contents of each profile are listed in
[modules/profiles/README.md](modules/profiles/README.md), per-machine
settings (boot, disk layout, zram, display, gaming) in
[modules/hosts/README.md](modules/hosts/README.md).

## Repository layout

| Path | Contents |
|---|---|
| [`modules/`](modules/README.md) | every Nix module, loaded by import-tree |
| [`modules/hosts.nix`](modules/hosts.nix) | the registry of machines and their users |
| [`modules/hosts/`](modules/hosts/README.md) | per-machine implementation: hardware, disko, display |
| [`modules/profiles/`](modules/profiles/README.md) | the `base` and `full` bundles and their building blocks |
| [`modules/schema/`](modules/schema/README.md) | the `profile` host option |
| [`modules/users/`](modules/users/README.md) | the `nazuna` user aspect |
| [`modules/system/`](modules/system/README.md) | boot, memory, power, keyboard, network, system tools |
| [`modules/nix/`](modules/nix/README.md) | Nix settings, binary caches, unfree |
| [`modules/shell/`](modules/shell/README.md) | git and the forge CLIs |
| [`modules/neovim/`](modules/neovim/README.md) | Vimzuna, the Neovim configuration |
| [`modules/desktop/`](modules/desktop/README.md) | niri, Noctalia, desktop services and apps |
| [`modules/gaming/`](modules/gaming/README.md) | games and their runtimes |
| [`modules/homes/`](modules/homes/README.md) | home-manager aspects |
| [`modules/homes/ai/`](modules/homes/ai/README.md) | coding agents, herdr and the Claude Code tooling |
| [`modules/homes/shell/`](modules/homes/shell/README.md) | shells and the terminal session |
| [`modules/homes/tui/`](modules/homes/tui/README.md) | terminal UIs |
| [`modules/apps/`](modules/apps/README.md) | `den-bootstrap`, `den-warm`, `den-rebuild`, `den-noctalia-save` |
| [`templates/`](templates/) | templates `den-bootstrap` renders for a new host |

## Documentation

- **[AI workflow overview](modules/homes/ai/README.md)**: the agents, herdr
  and how they fit together
- [Installing from a USB stick](docs/install.md)
- [Day-2 rebuilds](docs/den-rebuild.md)
- [Iterating in a VM](docs/vm.md)
- [Keyboard (AZERTY) in niri](docs/keyboard.md)
- [herdr and its plugins](docs/herdr.md)
- [OmO standalone](docs/omo.md)
- [Roadmap](docs/ROADMAP.md): architecture and phase status

## Not declarative, done once by hand

After the first boot:

- sign-ins: `sudo tailscale up`, OneDrive (Microsoft window on first mount),
  `gh auth login`, `glab auth login`, `claude` then `/login`, `codex login`,
  clauth profiles (`clauth capture`), OmO ([docs/omo.md](docs/omo.md)),
  Aerion accounts, Teams, WhatsApp
- Noctalia plugins: the config enables the tailscale plugin; install it from
  the GUI if it was not fetched
- Collie: `collie start` and `~/.config/collie/.env`
  ([docs/herdr.md](docs/herdr.md))
