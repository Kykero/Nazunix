# den-rebuild

Day-2 helper for a machine that is already installed: it brings the local
checkout up to date with `origin/main` and switches the running system to
it. Defined in `modules/apps/rebuild.nix`, built by CI with the other apps.

```bash
nix run ~/Nazunix#den-rebuild
```

It is a flake package, not a command on `PATH`: always go through
`nix run`.

## What it does

1. **Enters the checkout.** The path comes from `NH_OS_FLAKE` if set,
   otherwise from `NH_FLAKE`, which `programs.nh.flake` sets to
   `/home/nazuna/Nazunix` (`modules/nh.nix`). The path is never hardcoded
   a second time.
2. **Refuses local changes.** If `git status --porcelain` prints anything,
   it stops with `error: local changes present -- commit or stash first`.
   This guarantees the next step can never overwrite uncommitted work.
3. **Snapshots Noctalia.** `den-noctalia-save` (`modules/apps/noctalia-save.nix`)
   writes `noctalia config export` to
   `modules/desktop/noctalia/<host>.toml` and commits it if it changed.
   That file seeds `~/.config/noctalia/config.toml` after a reinstall.
4. **Rebases onto `origin/main` and pushes.** `git fetch origin`,
   `git rebase origin/main`, then `git push origin HEAD:main` when a
   snapshot commit is ahead. Only snapshot commits can be local here (step
   2), and each touches its own host file, so the rebase does not conflict.
   A failed push only warns; the switch goes on.
5. **Switches.** `exec nh os switch`, which builds the configuration of the
   current host, shows the package diff, and activates it.

## Arguments

Every argument is passed to `nh os switch` unchanged:

```bash
nix run ~/Nazunix#den-rebuild -- --dry   # build and diff, do not activate
nix run ~/Nazunix#den-rebuild -- --ask   # confirm before activating
```

The `--` separates `nix run`'s own options from the script's.

## Workflow

Changes are written on another machine, pushed to `main`, and evaluated by
the `check` workflow. Once `check` is green, `den-rebuild` on each machine
picks them up. It does not wait for CI: run it only after `check` passed.

## When it fails

| Message | Cause | Fix |
|---|---|---|
| `local changes present` | uncommitted edits in `~/Nazunix` | commit and push them, or `git stash` |
| rebase conflict | a local commit clashes with `origin/main` | `git rebase --abort`, sort the commit out by hand |
| `snapshot not pushed` | no push access (SSH key, network) | `git push` later; the next run retries |
| `NH_FLAKE: set by programs.nh` | nh not enabled on this system | run from a system built with the `nix-nh` aspect, or set `NH_FLAKE` |
| build error | the configuration does not build | check the `check` run for that commit |

## Related

- `den-bootstrap`: first install from the live ISO (see the README).
- `den-warm`: pull the full closure from the caches before a first switch
  from `-base`.
