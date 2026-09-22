# Draft — herdr (orchestration layer)

Short entry point. The two long drafts in this folder hold the design:
`herdr-claude-multi-account.md` (handoff v1, French, partly superseded) and
`herdr-claude-multi-account-review.md` (v2 confronted to the repo at
`e6f0762`, authoritative where they disagree).

## What it is

herdr is a terminal TUI/daemon that starts, lists and reattaches agent
sessions (Claude Code, others) and exposes a socket API; `herd` is the client
side; `herdr-automations` (community plugin, `DnzzL/herdr-automations`) adds
scheduling of prompts through that socket. It is an orchestration layer on
top of Claude Code, not a replacement: agents still run the real `claude`
binary with the real `~/.claude*` state.

Sources: upstream <https://github.com/ogulcancelik/herdr> (site
<https://herdr.dev>, AGPL-3.0-or-later, single Rust binary), packaging in
<https://github.com/numtide/llm-agents.nix>. Ecosystem worth a look before
reinventing: `jbaham2/herdr-plugin` (Claude Code plugin teaching the model
the herdr socket CLI), `vladzima/herd` (head agent delegating to worker
tabs — this is the "Herd" the v1 handoff meant), `mageyuki/herdr-top`
(live monitor), `DnzzL/herdr-automations` (scheduler).

## Decisions already taken (review draft)

- **Package:** `inputs.llm-agents.packages.<system>.herdr` (0.9.0 at review
  time, built from source with `rustPlatform` + Zig 0.15). Input pinned
  **without** `follows`, second exception after `niri`; roadmap §3 must be
  amended. Uses the numtide cache, declared in the `nix-caches` aspect.
- **Placement:** `home.packages` inside a `home-claude` aspect included from
  the user aspect `nazuna`, so it also lands on the `-base` gateway entities.
  Accepted for now.
- **Profiles:** herdr has **no** built-in profile concept. Two Claude
  accounts are isolated by two wrapper scripts `claude-a` / `claude-b`
  setting `CLAUDE_CONFIG_DIR` (and browser profiles, optional). herdr starts
  agents with `herdr agent start ... -- <args>`; arguments after `--` reach
  the agent, so a session is bound to an account by launching the right
  wrapper.
- **Daemon:** `herdr-automations` needs a live herdr server. Whether a
  headless `herdr server` exists is **open**; if not, a user `systemd` unit
  running the TUI detached (tmux/zellij) plus `loginctl enable-linger` is the
  fallback. Linger is not yet in the repo.
- **Plugin install** (`herdr plugin install DnzzL/herdr-automations`) is
  imperative and stays so.

## What agents inside herdr need

Everything from the sibling notes on `PATH` of the wrapped binaries: `gh`,
`glab`, `uv`/`uvx` (serena), `node`/`npx` (context7), optionally `rtk`.
See `claude-code-tooling.md` §3 for the split declarative/imperative.

## Blocked until a machine exists (roadmap phase 7)

All runtime tests V1-V10 of the review draft: OAuth login per profile,
Remote Control reattach from the phone, socket reachability for the
automations plugin, behaviour of two simultaneous `claude` processes on one
home. CI only evaluates; the `vm-yamori` VM does not exercise OAuth or
Remote Control.

## Open

- Release cadence of herdr; whether 0.9.x is still what `llm-agents.nix`
  ships at install time.
- `herdr` and `caveman`/`rtk` all touch what the model sees; only `rtk`
  rewrites tool output, the others are prompt-side. No conflict expected,
  never tested.
- Whether one herdr instance should own both accounts, or one instance per
  wrapper. The v2 handoff chose one instance; keep unless V-tests say
  otherwise.
