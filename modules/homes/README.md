# homes

Home-manager aspects: the user-level programs and their configuration.
Each file defines one den aspect, usually `home-<name>`, written either as
a plain `homeManager` class or as `provides.to-users.homeManager` (applied
to every user of the host that includes it).

| Folder | What it holds |
| --- | --- |
| [`ai/`](ai/README.md) | Claude Code, Codex, herdr, omo and the tools around them |
| [`shell/`](shell/README.md) | Shells and the terminal session: fish, bash, direnv, fd/ripgrep, tmux |
| [`tui/`](tui/README.md) | Terminal UIs: bat, btop, fastfetch, lazygit, television, yazi |

Nothing here is wired by its location: an aspect is active only where a
profile (`modules/profiles/`), a user (`modules/users/`) or another aspect
includes it, or, for `home-fish`, through `den.schema.user.includes`.
Each folder README says where its aspects are included.

`modules/shell/` is a different folder: it holds the git, `gh` and `glab`
aspects (`shell-*`), see [`../shell/README.md`](../shell/README.md).
