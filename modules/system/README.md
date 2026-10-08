# system

Machine-level NixOS aspects: boot, memory, power, keyboard, network and
system tools. Each file defines one den aspect with a `nixos` class.

| File | Aspect | What it does |
| --- | --- | --- |
| `boot-grub-efi.nix` | `boot-grub-efi` | GRUB on EFI only (`nodev`), systemd in the initrd, 20 generations in the menu, monthly btrfs scrub of `/`. Includes `grub-theme`. |
| `grub-theme.nix` | `grub-theme` | Elegant GRUB theme (mountain / float / left / light, 1080p) built from a pinned upstream source, with the NixOS logo. |
| `windows-dualboot.nix` | `windows-dualboot` | Explicit GRUB entry for Windows 11, found by its `bootmgfw.efi` file (no os-prober, no UUID), hardware clock in local time. |
| `zram.nix` | `zram` | zstd zram swap at 50% of RAM, swappiness tuned for zram, `/tmp` not on tmpfs. |
| `laptop-power.nix` | `laptop-power` | Lid switch: suspend on battery and on AC, ignore when docked. |
| `keyboard-fr.nix` | `keyboard-fr` | AZERTY console keymap (TTY and the `-base` gateway). |
| `tailscale.nix` | `tailscale` | Tailscale with the firewall opened for direct connections; joined once by hand with `sudo tailscale up`. |
| `devenv.nix` | `devenv` | The devenv binary system-wide; projects load it through direnv (`homes/shell/direnv.nix`). |

## Who includes what

- `profile-base` (`profiles/base.nix`): `keyboard-fr`, `devenv`, `tailscale`.
- Hardware aspects (`hosts/<machine>/<machine>.nix`, `<machine>-hw`), so
  both the full and the `-base` entity get them:
  - `dazai-hw`: `boot-grub-efi`, `zram`, `laptop-power`, `windows-dualboot`.
  - `yamori-hw`: `boot-grub-efi`, `windows-dualboot` (no zram, 32GB RAM).
- New hosts made by `den-bootstrap` get `zram` when the machine has less
  than 16GB of RAM (`templates/host/host.nix.in`).

niri and the greeter set their own xkb layout; the AZERTY niri binds are
described in [docs/keyboard.md](../../docs/keyboard.md).
