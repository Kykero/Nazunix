# shell

Git and the forge CLIs. Not to be confused with
[`../homes/shell/`](../homes/shell/README.md), which holds the shells
themselves (fish, bash, tmux...).

| File | Aspect | What it does |
| --- | --- | --- |
| `git.nix` | `shell-git` | git system-wide (NixOS `environment.systemPackages`): flakes fetch through it and root needs it (nh, rebuild) |
| `gh.nix` | `shell-gh` | GitHub CLI for every user (`provides.to-users`) |
| `glab.nix` | `shell-glab` | GitLab CLI for every user (`provides.to-users`) |

All three are included by the base profile (`modules/profiles/base.nix`),
so every host has them, `-base` gateways included.

## Notes

- The git identity is not declared in the repo: `bootstrap.nix` writes it
  from `git.env`, which stays off the repo.
- `gh auth login` keeps its token in the Secret Service (gnome-keyring)
  when the session provides one, in `hosts.yml` otherwise.
- `glab auth login` writes its token to `~/.config/glab-cli/config.yml`.
