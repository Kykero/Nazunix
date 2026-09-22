# Draft — llm-agents.nix (Claude Code + Codex runtimes)

Where the agent runtimes come from. The sibling herdr drafts already chose
this flake for `claude-code` and `herdr` (review draft §2). This note checks
those facts again, adds `codex` as a second runtime, and explains how both
connect to herdr. Nothing here is evaluated. It goes into `modules/` in one
batch with the neovim aspect (see §7).

Sources (read 2026-09-23): <https://github.com/numtide/llm-agents.nix>
(README, `flake.nix`, `lib/default.nix`,
`packages/{claude-code,codex,herdr}/package.nix`),
<https://herdr.dev/docs/agents/>, <https://herdr.dev/docs/integrations/>,
home-manager at the locked rev (`modules/programs/{codex,claude-code}`).

## 1. What the flake gives

| Attribute | Binary | Version (2026-09-23) | Build | License (meta) |
| --- | --- | --- | --- | --- |
| `claude-code` | `claude` | 2.1.280 | prebuilt native binary, wrapped | unfree (see below) |
| `codex` | `codex` | 0.155.1 | **from source**, `rustPlatform` + prebuilt `librusty_v8` | Apache-2.0 |
| `herdr` | `herdr` | 0.9.1 | **from source**, `rustPlatform` + Zig (libghostty-vt) | Apache-2.0 |

Also in the same flake, not taken for now: `collie` (mobile web UI for a
herdr herd over Tailscale), `codex-auth` (Codex account switcher, the Codex
equivalent of `claude-a`/`claude-b`), `codex-acp`, `claude-code-router`.

- **Cadence:** "Automatically updated daily". CI builds every package daily
  and pushes it to the numtide cache. Our pin moves only when `lock.yml` runs.
  Nothing updates itself: the `claude-code` wrapper sets
  `DISABLE_AUTOUPDATER=1`.
- **Unfree:** `claude-code` uses the flake's own `licenses.unfree` with
  `free = true` (`lib/default.nix`), so evaluating it does **not** need
  `allowUnfree` on our side. Nazunix sets no `allowUnfree` today, and this
  change does not need one.
- **Platforms:** `x86_64-linux`, `aarch64-linux`, `aarch64-darwin`. Both
  machines are covered.
- **herdr upstream moved:** the package now fetches `herdrdev/herdr` 0.9.1,
  and its meta says Apache-2.0. `herdr.md` still says `ogulcancelik/herdr`,
  AGPL-3.0, 0.9.0. Fix it when this note lands.

### `claude-code` wrapper (unchanged since the review draft, one correction)

`wrapProgram --argv0 claude`, `DISABLE_AUTOUPDATER=1`,
`DISABLE_INSTALLATION_CHECKS=1`, `--set-default
DISABLE_NON_ESSENTIAL_MODEL_CALLS=1`, and on Linux `bubblewrap` and `socat` on
`PATH`. `DISABLE_TELEMETRY` and `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` are
**off by default**, because they break Remote Control. They turn on only
through `claude-code.override { disableTelemetry = true; }`. Never do that
here (herdr V-tests rely on Remote Control). Test V11 of the review draft is
therefore mostly answered by the package source: only
`DISABLE_NON_ESSENTIAL_MODEL_CALLS` is left to check on a real machine.

### `codex` build cost

Built from the `openai/codex` Rust workspace (tag `rust-v<version>`). The
package comments say that upstream's ThinLTO build peaks around 12 GiB in
rustc. They patch that out, but it is still a large Rust build. On `dazai`
(8 GB) a cache miss is not acceptable. The numtide cache is **mandatory**,
not optional, which is one more reason for no `follows` (§2).

## 2. Flake input and consumption

```nix
# flake.nix — inputs
llm-agents.url = "github:numtide/llm-agents.nix";   # no follows: see below
```

- **No `follows`.** The README says the flake is only built and tested
  against its own pinned `nixpkgs-unstable`, and that omitting `follows`
  "lets you pull pre-built binaries from our binary cache". This makes it the
  **first** exception to the rule in `docs/ROADMAP.md` §3 ("Every input
  `follows` nixpkgs"). `niri` now follows nixpkgs, so the review draft's
  "sauf `niri`" is out of date. Add the exception clause to that sentence in
  the same commit. Cost: a second nixpkgs in `flake.lock`, evaluated only for
  these packages.
- **Consume `packages.${system}`, not the overlay.**
  `overlays.shared-nixpkgs` exposes `pkgs.llm-agents.*` built against *our*
  nixpkgs, and the README warns that the binary cache "only hits when your
  nixpkgs revision matches ours". With `codex` and `herdr` built from source,
  that means local Rust builds. Use
  `inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.<name>`,
  with `inputs` captured by closure (same pattern as
  `modules/nix/settings.nix`).
- `lock.yml` is run manually after the input is added (existing rule).

## 3. Binary cache

The flake's own `nixConfig` (`extra-substituters` /
`extra-trusted-public-keys`) only applies to `nix run github:numtide/...`, not
when it is an input. Nazunix has no `nixConfig` anyway. It goes into the
`nix-caches` aspect (`modules/nix/caches.nix`):

```nix
substituters = [ ... "https://cache.numtide.com" ];
trusted-public-keys = [
  ...
  "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
];
```

This key comes from the README **and** from their `flake.nix` `nixConfig`, and
both match. Free side effects, as the review draft notes: `check.yml` reads
the substituters from the evaluated config, and `den-bootstrap` writes them
into `/etc/nix/nix.conf` of the `-base` entities before `full` is pulled.

## 4. Codex vs. Claude Code: state, auth, config dir

| | Claude Code | Codex |
| --- | --- | --- |
| Config dir | `~/.claude`, override `CLAUDE_CONFIG_DIR` | `~/.codex`, override `CODEX_HOME` |
| Auth | OAuth in the config dir / `~/.claude.json` | `codex login` (ChatGPT OAuth or API key), stored in `$CODEX_HOME/auth.json` |
| Multi-account | `claude-a` / `claude-b` wrappers (review draft) | one account for now; `codex-auth` or a `codex-b` wrapper setting `CODEX_HOME` if ever needed |
| Instructions file | `CLAUDE.md` | `AGENTS.md` |
| Sandbox | `bubblewrap` + `socat` injected by the wrapper | `bubblewrap` bundled and on the wrapper `PATH` (Linux sandbox) |

Auth stays imperative and outside the repo, as in `gh.md` and `glab.md`. It
is a post-install step per machine: `codex login` once, then `claude-a` and
`claude-b` logins as in the review draft.

**Do not use `programs.codex` / `programs.claude-code` settings for now.**
Home Manager (locked rev) has both modules. Their `settings` / `hooks`
options turn `config.toml`, `hooks.json` and `settings.json` into read-only
store files. `herdr integration install` (§5) and Claude Code itself must
*write* those files. Plain `home.packages` keeps them writable. A declarative
version (herdr hooks written as HM `hooks`) is possible later, but not
before the V-tests. Also: with `home.preferXdgDirectories = true`,
`programs.codex` moves the config to `~/.config/codex` and sets `CODEX_HOME`.
Keep that in mind if the module is adopted.

## 5. How it connects to herdr

herdr does not wrap the agents. It "owns their terminals" and runs the real
binary found on `PATH` (see `herdr.md`). Both runtimes are in its supported
list:

- **Detection:** Claude Code and Codex are both classified by *screen
  manifest detection* (idle / working / blocked read from the terminal
  buffer). No hook is needed for herdr to see them.
- **Session identity / restore:** optional integrations, imperative, per
  config dir:

  ```sh
  herdr integration install claude   # writes $CLAUDE_CONFIG_DIR/hooks/herdr-agent-state.sh + hook entries in settings.json
  herdr integration install codex    # writes $CODEX_HOME/herdr-agent-state.sh, hooks.json, sets [features] hooks = true in config.toml
  ```

  Both respect the override variable, and both require the config dir to
  exist first. For the two Claude accounts, run the install **once per
  profile**, with `CLAUDE_CONFIG_DIR` set to each profile dir (or from inside
  `claude-a` / `claude-b`), unless the shared `settings.json` symlink from
  the review draft §4 makes one install cover both. Check which in phase 7.
  `herdr integration uninstall codex` leaves `config.toml` changed. That is
  harmless.
- **Launching:** `herdr agent start ... -- <args>` passes everything after
  `--` unchanged. A Codex pane is started with `codex`, and a Claude pane with
  `claude-a` or `claude-b`, never the bare `claude` from the package (it would
  bypass the wrapper and the account split).
- **Same `PATH` rule as the forge CLIs:** `gh`, `glab`, `uv`, `node` must be
  in `home.packages` so that `codex` running under herdr sees them too
  (README "Shared constraints").
- **Editor:** both runtimes open `$VISUAL` / `$EDITOR` for long prompts, which
  is why this lands together with the neovim aspect (§7).

## 6. Things to verify in phase 7

- V-C1: `codex --version` and `claude --version` come from the numtide cache.
  `nix path-info --store https://cache.numtide.com` for both, and no Rust
  build in the rebuild log on `dazai`.
- V-C2: `codex login` from a niri session (browser callback) and from an SSH
  session (device-code flow).
- V-C3: `herdr integration install codex`, then a Codex pane is restored with
  its session after a herdr restart.
- V-C4: `herdr integration install claude` per Claude profile. Hooks end up
  in the file herdr expects, even though `settings.json` is shared.
- V-C5: `DISABLE_NON_ESSENTIAL_MODEL_CALLS=1` does not affect Remote Control
  (what is left of review V11).
- V-C6: `codex` inside herdr finds `gh` / `glab` on `PATH` (non-login shell).

## 7. Sketch for later (not committed)

Lands in one batch with neovim, after the input and cache commits. One file
per tool, included from the user aspect `nazuna` like `home-bash` and
`home-btop`, so both runtimes also reach the `-base` gateways (accepted in
the review draft §3, same decision to take once for all `home-*` agent
aspects). `claude-code` and `herdr` stay in `home-claude`
(`modules/homes/claude.nix`, review draft), and Codex gets its own aspect.

Suggested commit order: (1) `flake.nix` input + ROADMAP §3 exception clause,
`lock.yml`; (2) numtide cache in `modules/nix/caches.nix`;
(3) `modules/homes/neovim.nix`; (4) `modules/homes/claude.nix` (wrapper,
`claude-a`/`claude-b`, herdr, linger); (5) `modules/homes/codex.nix`;
(6) includes in `modules/users/nazuna.nix`. One `check` run per commit.

```nix
# modules/homes/codex.nix — sketch
{ inputs, ... }:
{
  den.aspects.home-codex.homeManager =
    { pkgs, ... }:
    let
      llm = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      # plain package, not programs.codex: herdr integration must be able to
      # write $CODEX_HOME/{config.toml,hooks.json} (see §4)
      home.packages = [ llm.codex ];
    };
}
```

```nix
# modules/homes/claude.nix — excerpt, the package side only (full design in
# herdr-claude-multi-account-review.md §3)
{ inputs, ... }:
{
  den.aspects.home-claude = {
    homeManager =
      { pkgs, ... }:
      let
        llm = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        home.packages = [
          llm.herdr
          # claude-a / claude-b wrappers built on llm.claude-code; never put
          # llm.claude-code itself here, it would shadow the wrapper
        ];
      };
    nixos = { user, ... }: { users.users.${user.userName}.linger = true; };
  };
}
```

```nix
# modules/users/nazuna.nix — includes, later
den.aspects.home-neovim
den.aspects.home-claude
den.aspects.home-codex
```

## Open

- Include from `nazuna` (the `-base` gets two Rust-built binaries, from the
  cache) or from `profile-full`. Same decision as review draft §3.
- Second Codex account: `codex-auth` from the same flake, or a `CODEX_HOME`
  wrapper mirroring `claude-a`/`claude-b`. Not needed today.
- `collie` (phone UI for herdr) only once Tailscale is on the roadmap.
- Declarative `programs.codex` / `programs.claude-code` after the V-tests, if
  herdr hooks can be expressed as HM `hooks` without losing restore.
