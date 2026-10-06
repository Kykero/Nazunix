# Nazunix

Declarative NixOS for a small personal fleet (`yamori` desktop, `dazai`
laptop, user `nazuna`), built on flake-parts, import-tree and the den
framework. Desktop: niri + Noctalia, AZERTY; ghostty, fish and Zen Browser
for every user.

The repo is the installer: `den-bootstrap` runs from a NixOS live USB, wipes
the chosen disk, installs the `-base` gateway and then the full profile.

## What an installed machine gets

Every host runs the `full` profile; its `-base` twin (the install gateway)
runs only the first block.

**Base** (every host, `-base` included)
- Nix: flakes, the flake's nixpkgs as the system one, binary caches
  (cache.nixos.org, numtide, nix-community), unfree allowed, `nh` with
  automatic gc
- AZERTY on the console, NetworkManager, OpenSSH
- Tailscale daemon
- Neovim from Vimzuna (`nvim`, `vimzuna`), vim, btop
- git, `gh`, `glab`, devenv + direnv (nix-direnv)
- user `nazuna` (wheel), fish as login shell, bash kept for scripts
- `den-rebuild` / `den-warm` for day-2 rebuilds

**Desktop** (full)
- niri from nixpkgs, AZERTY binds, window rules, two named workspaces,
  background blur
- Noctalia v5: bar, launcher, notifications, lock screen, and its greetd
  greeter as the login screen; base config from
  `modules/desktop/noctalia/config.toml`
- PipeWire, BlueZ, UPower + power-profiles-daemon
- Ghostty (terminal), Zen Browser, Nautilus (+ gvfs), Zathura (PDF),
  JetBrains Mono Nerd Font, GTK apps themed from Noctalia (adw-gtk3)
- OneDrive mounted on demand at `~/OneDrive` (onedriver, FUSE; quota
  cached so Nautilus does not freeze)
- Obsidian, Aerion (mail, Gmail/Microsoft OAuth), Teams
  (teams-for-linux), WhatsApp (whatsapp-electron)

**AI** (full)
- Claude Code and Codex CLIs, the Claude and ChatGPT/Codex desktop apps
- herdr, OmO, zoetrope, herdr-projects, Collie
- Claude Code tooling: superpowers and caveman plugins, SuperClaude
  (`/sc:*` commands and agents), context7 and serena MCP servers, rtk hook,
  graphify skill

**Per machine**
- both: GRUB (EFI, Elegant theme), systemd initrd, btrfs on the whole disk
  (`@root`, `@home`, `@nix`, `@log`, zstd) laid out by disko, monthly scrub
- `dazai` (laptop, 8 GB): zram swap, lid suspend, display scale 1.2
- `yamori` (desktop, 32 GB): no zram

**Not declarative, done once by hand after the first boot**
- sign-ins: `sudo tailscale up`, OneDrive (Microsoft window on first
  mount), `gh auth login`, `glab auth login`, `claude` then `/login`,
  `codex login`, OmO, Aerion accounts, Teams, WhatsApp
- Noctalia plugins: the config enables the tailscale plugin, install it
  from the GUI if it is not fetched; GUI tweaks override the declarative config,
  fold them back with `noctalia config export`
- herdr integrations and plugins, Collie (`collie start`,
  `~/.config/collie/.env`), see [herdr.md](docs/herdr.md)

## Documentation

- [Installing from a USB stick](docs/install.md): preparing the stick and the
  keys directory, `den-bootstrap`, first boot, day-2 rebuilds
- [Day-2 rebuilds](docs/den-rebuild.md): what `den-rebuild` does, its
  arguments and failure modes
- [Iterating in a VM](docs/vm.md): `nix run .#vm-<host>`, the rebuild and
  relaunch loop, live niri tweaks, resetting the disk image
- [Keyboard (AZERTY) in niri](docs/keyboard.md): transposed binds and the
  Noctalia shortcuts
- [herdr and its plugins](docs/herdr.md): seeded config and Noctalia
  theme, herdr-projects, zoetrope, Collie, and their one-time setup
- [OmO standalone](docs/omo.md): the `omo` agent on trial next to herdr,
  Claude and ChatGPT sign-ins, where its state lives
- [Roadmap](docs/ROADMAP.md): architecture and phase status
