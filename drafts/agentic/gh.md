# Draft — GitHub CLI (`gh`)

Windows machine had `gh` 2.94.0 (2026-06-10), logged in through the OS keyring,
no extensions, no aliases, `config.yml` empty. Everything agents used it for
went through the plain commands: `gh pr`, `gh issue`, `gh run`, `gh api`,
`gh ssh-key`. Source: <https://github.com/cli/cli>.

## Why it matters here

- Claude Code is told to use `gh` for every GitHub operation (PRs, issues,
  API). `check.yml` verdicts are read with `gh run list` / `gh run view --log`;
  the repo's ground rule "push and read the run" is a `gh` call.
- `rtk gh` wraps it for compact output if rtk is adopted (see
  `claude-code-tooling.md` §4).
- The `clockify-worklog` skill used `gh issue view` as one of its two inputs;
  the skill is gone, the pattern (agent reads issue, writes back a comment)
  stays.

## Package

`nixpkgs#gh`. One aspect, e.g. `modules/homes/gh.nix`, included from `nazuna`:

```nix
{ den, ... }:
{
  den.aspects.home-gh = {
    homeManager = { pkgs, ... }: {
      programs.gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
          prompt = "disabled";   # agents must never hit an interactive prompt
          aliases = { };
        };
      };
    };
  };
}
```

`programs.gh` writes `~/.config/gh/config.yml` only; `hosts.yml` (tokens,
users) stays untouched, which is what we want. Unverified: whether
`programs.gh` conflicts with the `gh` binary from `llm-agents.nix` if that
input ever exposes one — it does not today, so take `nixpkgs`.

## Auth (imperative, per machine)

```sh
gh auth login --git-protocol ssh --hostname github.com --web
```

Token lands in the keyring (`secret-service` on a niri session needs a
running agent: `gnome-keyring` or `keepassxc` with secret-service enabled —
decide in the desktop phase, otherwise `gh` falls back to plaintext in
`hosts.yml`). Two Claude accounts do **not** need two `gh` logins: both
wrappers share the same `nazuna` home and the same GitHub identity.

SSH is the transport for git itself; `gh` only needs the token for the API.
Key registered for the laptop is `nazunix-dazai` (also the signing key
`nazuna`). Windows key `WSL` was revoked 2026-09-22.

## Things to verify in phase 7

- `gh auth status` from inside `claude-a` (wrapped binary, non-login shell):
  token found, no prompt.
- `gh run view --log` output size vs. context: compare raw and `rtk gh run`.
- `git_protocol = ssh` + `gh repo clone` uses the `nazunix-dazai` key, not a
  fallback agent key.

## Later

- `gh extension install` for `gh-dash` or similar is imperative and lives
  outside Nix; skip unless a real need appears.
- Signing: repo requires the noreply author, and GitHub now holds a signing
  key. `programs.git.signing` + `gpg.format = "ssh"` belongs in a `git` aspect,
  not here.
