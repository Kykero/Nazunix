# shell

Git and the forge CLIs. Not to be confused with
[`../homes/shell/`](../homes/shell/README.md), which holds the shells
themselves (fish, bash, tmux...).

| File | Aspect | What it does |
| --- | --- | --- |
| `git.nix` | `shell-git` | git system-wide (NixOS `environment.systemPackages`): flakes fetch through it and root needs it (nh, rebuild); home-manager's git with the GitHub identity for every user |
| `gh.nix` | `shell-gh` | GitHub CLI for every user (`provides.to-users`) |
| `glab.nix` | `shell-glab` | GitLab CLI for every user (`provides.to-users`) |

All three are included by the base profile (`modules/profiles/base.nix`),
so every host has them, `-base` gateways included.

## Notes

- The git identity is the GitHub handle and its noreply address
  (`git.nix`), never a real email. `bootstrap.nix` still writes the
  checkout's local identity from `git.env` for its install commit.
- `gh auth login` keeps its token in the Secret Service (gnome-keyring)
  when the session provides one, in `hosts.yml` otherwise.
- `glab auth login` writes its token to `~/.config/glab-cli/config.yml`.
