# desktop

The graphical session: niri, the Noctalia shell, desktop services and
desktop apps. One concern per file; most files define one
`desktop-<name>` aspect.

## Session and shell

| File | Aspect | What it does |
| --- | --- | --- |
| `niri.nix` | `desktop-niri` | niri from nixpkgs through `programs.niri` (wayland session, portals, gnome-keyring, polkit). |
| `niri-home.nix` | `desktop-niri-home` | User niri config through niri-flake's settings module, validated at build time; keyboard AZERTY + US. |
| `niri-binds.nix` | `desktop-niri-binds` | niri's default binds transposed to AZERTY. |
| `niri-window-rules.nix` | `desktop-niri-window-rules` | Window rules (rounded, clipped corners). |
| `niri-workspaces.nix` | `desktop-niri-workspaces` | Two named workspaces that persist from session start. |
| `niri-focus-follows-mouse.nix` | `desktop-niri-focus-follows-mouse` | Focus follows the pointer. |
| `niri-blur.nix` | `desktop-niri-blur` | Background blur behind windows and Noctalia's surfaces, appended as raw KDL. |
| `niri-xwayland.nix` | `desktop-niri-xwayland` | xwayland-satellite in `PATH` so niri can start X11 clients. |
| `noctalia.nix` | `desktop-noctalia` | Noctalia shell (bar, launcher, notifications, lock screen); seeds its config once. |
| `greeter.nix` | `desktop-greeter` | Noctalia's greetd greeter, with passwordless appearance sync. |
| `gtk-theme.nix` | `desktop-gtk-theme` | GTK follows Noctalia's colours; owns `gtk-4.0/gtk.css` so other aspects can add sheets. |
| `fonts.nix` | `desktop-fonts` | JetBrains Mono Nerd Font system-wide. |

## Services

| File | Aspect | What it does |
| --- | --- | --- |
| `audio.nix` | `desktop-audio` | PipeWire (ALSA, Pulse) and rtkit; Noctalia needs a running daemon. |
| `easyeffects.nix` | `desktop-easyeffects` | EasyEffects user service: EQ, compressor, noise suppression on the mic. |
| `bluetooth.nix` | `desktop-bluetooth` | BlueZ, powered on at boot. |
| `power.nix` | `desktop-power` | UPower and power-profiles-daemon, which Noctalia talks to. |
| `onedrive.nix` | `desktop-onedrive` | onedriver FUSE mount at `~/OneDrive` as a user service; token stays in `~/.cache/onedriver`. |
| `onedrive-statfs.nix` | `desktop-onedrive` | Overlay that caches onedriver's quota answer so Nautilus stops freezing. |
| `localsend.nix` | `desktop-localsend` | LocalSend through its NixOS module, firewall port opened. |
| `vm.nix` | `desktop-vm` | Settings under `virtualisation.vmVariant` only, for `nix run .#vm-<host>`. |

## Apps

| File | Aspect | What it does |
| --- | --- | --- |
| `terminal.nix` | `desktop-terminal` | Ghostty, single GTK instance, translucent, colours from Noctalia's template. |
| `browser.nix` | `desktop-browser` | Zen Browser through its home-manager module, set as default browser. |
| `files.nix` | `desktop-files` | Nautilus and gvfs, used by the portal's file chooser; translucent style. |
| `pdf.nix` | `desktop-pdf` | Zathura with the mupdf plugin for PDFs. |
| `audio-mixer.nix` | `desktop-audio-mixer` | pwvucontrol, PipeWire volume mixer (per-app levels, mic gain). |
| `obsidian.nix` | `desktop-obsidian` | Obsidian through `programs.obsidian`, with its CLI. |
| `mail.nix` | `desktop-mail` | Aerion mail client, with the OAuth helper for Gmail and Microsoft. |
| `outlook.nix` | `desktop-outlook` | Outlook on the web in a chromeless Chromium window with its own profile. |
| `teams.nix` | `desktop-teams` | teams-for-linux. |
| `whatsapp.nix` | `desktop-whatsapp` | whatsapp-electron. |
| `discord.nix` | `desktop-discord` | Official Discord client (unfree). |

## Noctalia seeds (`noctalia/`)

Not Nix files, so import-tree ignores them.

- `noctalia/base.toml`: seed for a machine without its own snapshot.
- `noctalia/<host>.toml` (currently `dazai.toml`): the machine's last
  snapshot, written and committed by `den-noctalia-save`
  (`apps/noctalia-save.nix`, run by `den-rebuild`). Edit from the GUI, not
  by hand.

`noctalia.nix` copies `noctalia/<host>.toml`, or `base.toml` if there is
none, to `~/.config/noctalia/config.toml` once, writable, then leaves it
alone.

## How it composes

- `profile-desktop` (`profiles/desktop.nix`) includes every aspect above
  except the five communication apps, which come through `profile-comms`
  (`profiles/comms.nix`, included by `profile-desktop`). `profile-full`
  includes `profile-desktop`; `-base` entities get none of this.
- Most user-side config is written as `provides.to-users.homeManager`: a
  plain `homeManager` class on a host-included aspect is inert in den.
- The Claude and Codex desktop apps (`desktop-claude-app`,
  `desktop-codex-app`) moved to `homes/ai/` and are included by
  `profiles/ai.nix`.

Related docs: [docs/keyboard.md](../../docs/keyboard.md) (binds),
[docs/vm.md](../../docs/vm.md) (VM),
[docs/den-rebuild.md](../../docs/den-rebuild.md) (Noctalia snapshots).
