# Draft — GitLab CLI (`glab`)

Windows machine had `glab` 1.105.0, used for work repos on a self-hosted
GitLab (issues, MRs, pipelines). Its config file was not found in the usual
paths during the pre-wipe inventory, so treat the setup as unknown: redo
auth from scratch. Source: <https://gitlab.com/gitlab-org/cli>.

**Privacy note for this repo:** the work GitLab hostname, group paths and
project names never appear here. Configure them locally, reference them in
notes as `<gitlab-host>`.

## Why it matters here

- Same role as `gh` but for the work side: agents read issues, open MRs,
  watch pipelines. `rtk glab` exists too.
- The former `clockify-worklog` skill took a GitLab issue as input; if a
  replacement is ever written it needs `glab issue view` and `glab mr` working
  non-interactively.

## Package

`nixpkgs#glab`. No Home Manager module exists for it (as of writing —
verify with `context7` `/nix-community/home-manager` before assuming), so it
is a plain package plus a hand-managed config:

```nix
{ den, ... }:
{
  den.aspects.home-glab = {
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.glab ];
    };
  };
}
```

Do **not** template `~/.config/glab-cli/config.yml` from Nix: it holds the
token and the hostname, both out of scope for a public repo until sops-nix.

## Auth (imperative, per machine)

```sh
glab auth login --hostname <gitlab-host>
```

Interactive; choose token auth with a PAT scoped `api` + `write_repository`.
Set the default host once so agents never get asked:

```sh
glab config set -g host <gitlab-host>
glab config set -g git_protocol ssh
glab config set -g check_update false
```

`check_update false` matters: the update nag goes to stderr and pollutes
agent output.

A separate SSH key for the work GitLab is probably wanted (different identity
than GitHub). That is an `ssh` aspect concern (`programs.ssh.matchBlocks`),
not a `glab` one; note it in the herdr/isolation design if the work account
must be kept away from one of the two Claude profiles.

## Things to verify in phase 7

- `glab auth status` from inside a wrapped `claude-*` binary.
- `glab ci view` / `glab ci trace` output size; whether `rtk glab` trims it.
- Behaviour when both a GitHub remote and a GitLab remote exist in one repo
  (`glab` picks `origin` by default — set `glab config set remote_alias` if
  the work remote is not `origin`).

## Open

- Does Nazunix even need `glab` on `yamori` (personal desktop), or only on
  `dazai` (laptop, work)? Lean: include the aspect from `nazuna` on both,
  auth only where used.
