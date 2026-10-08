# homes/tui

Terminal UIs, most of them also driven from Neovim.

| File | Aspect | What it does |
| --- | --- | --- |
| `bat.nix` | `home-bat` | bat, cat with syntax highlighting; television previews files with it |
| `btop.nix` | `home-btop` | btop with vim keys and a transparent background |
| `fastfetch.nix` | `home-fastfetch` | fastfetch with an explicit module list |
| `lazygit.nix` | `home-lazygit` | lazygit; Neovim opens it on `<leader>gg` (snacks.nvim) |
| `television.nix` | `home-television` | television (`tv`); its fish integration binds Ctrl+T and Ctrl+R |
| `yazi.nix` | `home-yazi` | yazi, with the `y` fish wrapper that cds into the last directory on quit |

## Where they are included

- `home-yazi`, `home-television`, `home-lazygit`, `home-bat`: the base
  profile (`modules/profiles/base.nix`), as `provides.to-users`.
- `home-btop`, `home-fastfetch`: the `nazuna` user
  (`modules/users/nazuna.nix`).

## Notes

- Neovim does not depend on these aspects: its own vimzuna aspects
  (`modules/neovim/television.nix`, `yazi.nix`, `snacks.nix`) add the
  binaries it calls to the editor's `extraPackages`. These files put the
  same tools in every shell, with their configuration.
- fastfetch leaves out the Packages module, which spawns `nix-store`
  queries on every run (slow after each rebuild), plus DE and WMTheme
  (nothing to report under niri) and LocalIp (keeps addresses out of
  screenshots).
