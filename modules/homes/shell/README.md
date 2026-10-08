# homes/shell

The user's shells and terminal session.

| File | Aspect | What it does |
| --- | --- | --- |
| `fish.nix` | `home-fish` | fish as every user's login shell (`den.batteries.user-shell "fish"`), no greeting, `ll`/`la` aliases |
| `bash.nix` | `home-bash` | bash kept for scripts and recovery: completion, deduplicated history, `ll`/`la`/`..` aliases |
| `direnv.nix` | `direnv` | direnv with nix-direnv (cached, gc-rooted environments), silent; hooked into fish by home-manager |
| `search.nix` | `home-search` | fd and ripgrep, also the sources of television's files and text channels |
| `tmux.nix` | `home-tmux` | tmux: mouse, no escape delay, resurrect + continuum, Ctrl+hjkl / Alt+hjkl shared with Neovim |
| `tmux-status.nix` | `home-tmux-status` | one-line status bar at the top, terminal palette colors only |

## Where they are included

- `home-fish`: every user, through `den.schema.user.includes`, on every
  host (base and full). No user or profile names it.
- `home-bash`: the `nazuna` user (`modules/users/nazuna.nix`).
- `direnv`, `home-search`: the base profile (`modules/profiles/base.nix`).
- `home-tmux`: the `neovim` aspect (`modules/neovim/ide.nix`), which
  needs it for the `vimzuna` session. `home-tmux` includes
  `home-tmux-status`.

## Notes

- Ctrl+hjkl moves and Alt+hjkl resizes. When the pane runs Neovim
  (`@pane-is-vim`, set by smart-splits.nvim) the key is passed through, so
  the same keys cross Neovim splits and tmux panes. The Neovim side is
  `modules/neovim/navigation.nix`.
- tmux sessions, pane contents included, are saved by resurrect every 15
  minutes and restored by continuum when the server starts. tmux is not
  started by fish; it is opened on demand.
- The status bar is written with `lib.mkBefore` into `tmux.conf`, before
  the plugins: continuum appends its autosave hook to `status-right` when
  it loads, and a later `status-right` would drop it.

`modules/shell/` is a different folder: git, `gh` and `glab`, see
[`../../shell/README.md`](../../shell/README.md).
