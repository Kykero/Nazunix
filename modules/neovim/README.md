# neovim

Vimzuna, the Neovim configuration, built by nvf's NixOS module and
installed on every host by the base profile.

## How it composes

- `namespace.nix` declares a local den namespace, `vimzuna`, so editor
  aspects with short names (`core`, `lsp`, `yazi`...) never collide with
  `den.aspects`.
- Each editor concern is a `vimzuna.<name>` aspect written in a `vim`
  class, i.e. nvf's `config.vim`.
- `profile.nix` defines `vimzuna.nvim`, the list of aspects actually
  installed.
- `neovim.nix` defines `den.aspects.neovim`: it imports nvf's NixOS
  module, enables `programs.nvf` as the default editor, and forwards the
  `vim` class of `vimzuna.nvim` into `programs.nvf.settings.vim`
  (`den.batteries.forward`).
- `ide.nix` adds to the same `neovim` aspect the `vimzuna` command and
  includes `home-tmux` ([`../homes/shell/`](../homes/shell/README.md)).

## Files

| File | Defines | What it does |
| --- | --- | --- |
| `namespace.nix` | `vimzuna` namespace | the local namespace holding the editor aspects |
| `neovim.nix` | `den.aspects.neovim` | nvf on NixOS, `vim` class forwarded into `programs.nvf` |
| `ide.nix` | `den.aspects.neovim` | `vimzuna`: attach or create the `vimzuna` tmux session with nvim in its `nvim` window |
| `profile.nix` | `vimzuna.nvim` | every vimzuna aspect but `vimtex` |
| `core.nix` | `vimzuna.core` | vi/vim aliases, Space leader, tokyonight moon, options, fr/en spellcheck, lualine, which-key, Wayland clipboard |
| `python.nix` | `vimzuna.python` | Python 3 provider with pynvim |
| `snacks.nix` | `vimzuna.snacks` | snacks.nvim: dashboard, notifier, lazygit (`<leader>gg`), GitHub issue/PR pickers (`<leader>gi/gI/gp/gP`) |
| `navigation.nix` | `vimzuna.navigation` | smart-splits.nvim: Ctrl+hjkl move, Alt+hjkl resize across splits and tmux panes |
| `yazi.nix` | `vimzuna.yazi` | yazi.nvim on `<leader>n` / `<leader>N` |
| `television.nix` | `vimzuna.television` | tv.nvim: files `<leader>ff`, text `<leader>fg`, channels `<leader>fc` |
| `claude.nix` | `vimzuna.claude` | claudecode.nvim (`<leader>ac/as/ab/aa/ad`) |
| `autopairs.nix` | `vimzuna.autopairs` | nvim-autopairs |
| `lsp.nix` | `vimzuna.lsp` | LSP, blink-cmp, format on save, trouble, lightbulb, `<leader>lf` format |
| `languages.nix` | `vimzuna.languages` | treesitter, formatters and LSPs for Nix (nixd, nixfmt), Markdown, Bash, Python (basedpyright, debugpy), JSON, Java |
| `vimtex.nix` | `vimzuna.vimtex` | VimTeX, texlive-full, zathura SyncTeX; not installed |

## Notes

- `vimtex` is left out of `vimzuna.nvim` because texlive-full is several
  GB; add it to `profile.nix`'s includes to get it.
- claudecode.nvim does not provide the `claude` CLI: that comes with the
  full profile, see [`../homes/ai/`](../homes/ai/README.md). Inside tmux,
  Claude opens in a new pane on the right (external terminal provider);
  outside tmux the native terminal is used.
- The tmux half of the Ctrl+hjkl / Alt+hjkl contract is
  `modules/homes/shell/tmux.nix`: keys are passed through to Neovim when
  `@pane-is-vim` is set.
- The editor's `extraPackages` carry the binaries its plugins call
  (television, bat, fd, ripgrep, yazi, lazygit, gh); the same tools are
  in every shell through [`../homes/tui/`](../homes/tui/README.md) and
  `home-search`.
