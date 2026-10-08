# modules/profiles/

Bundles of aspects. A host never lists features itself: its `profile`
option picks `profile-base` or `profile-full` through the pointcut in
[`../schema/`](../schema/README.md), and these files say what that means.

| File | Aspect | Includes |
|---|---|---|
| `base.nix` | `profile-base` | Nix settings and caches, nh, AZERTY keyboard, Neovim, devenv, direnv, Tailscale, git/gh/glab, the TUI tools yazi, television, lazygit, bat and search; plus vim, btop, the Paris time zone, OpenSSH and NetworkManager |
| `desktop.nix` | `profile-desktop` | the niri session (binds, window rules, workspaces, blur, XWayland), Noctalia, the greeter, fonts, terminal, browser, files, PDF, GTK theme, Obsidian, OneDrive, LocalSend, audio, power, Bluetooth, the full-profile VM settings, and `profile-comms` |
| `comms.nix` | `profile-comms` | mail, Outlook, Teams, WhatsApp |
| `ai.nix` | `profile-ai` | Claude Code and Codex with their desktop apps, herdr and its integrations, OmO (with omo-graph and the `pi` shim that lets herdr-projects start it), herdr-projects, zoetrope, Collie, clauth, Claude plugins, SuperClaude, the Context7 and Serena MCP servers, rtk, graphify |
| `full.nix` | `profile-full` | `profile-base`, `profile-desktop`, `profile-ai` |

## Notes

- Only `base` and `full` are host profiles (the schema enum). `desktop`,
  `comms` and `ai` are building blocks of `full`.
- `base` is what the `-base` install gateways boot: small and cache-friendly.
  `profile-ai` is full-only so the gateways never pull the agent packages
  during bootstrap.
- The aspects come from [`../desktop/`](../desktop/README.md),
  [`../homes/`](../homes/README.md) (its `ai/` folder for `profile-ai`),
  [`../system/`](../system/README.md), [`../nix/`](../nix/README.md),
  [`../shell/`](../shell/README.md) and [`../neovim/`](../neovim/README.md).
- Some home aspects are not in any profile: the user aspect adds bash, btop
  and fastfetch ([`../users/`](../users/README.md)), and fish is included
  for every user from `homes/shell/fish.nix`.
- Per-machine settings are not in any profile: boot (GRUB on EFI), the
  btrfs layout from disko, zram, display and pointer settings, and extras
  such as `gaming` come from [`../hosts/`](../hosts/README.md).
