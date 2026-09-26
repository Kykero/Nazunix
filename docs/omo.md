# OmO standalone

[OmO](https://omo.dev) (`omo`, package `omo-ai` from llm-agents) is a
terminal coding agent: the OMO plugin running on the senpi engine, a fork
of pi. It is on trial next to herdr, in the `full` profile only. herdr
stays for `claude` and `codex`: omo shows one session per TUI, and herdr
has no omo integration, so an omo pane gets no working/blocked state.

What Nix provides, and what stays imperative:

| | Nix (repo) | By hand, once per machine |
|---|---|---|
| omo | binary (`homes/omo.nix`) | sign-ins, default model |
| config | nothing | `~/.omo/omo.jsonc` if ever needed |

## Sign in

There is no login subcommand. Sign-ins are slash commands inside `omo`:

1. `omo`, then `/login anthropic-subscription`. Sign in in the browser.
   This provider drives the real Claude Code (the llm-agents `claude`, set
   by the package wrapper), so that Claude Code must be recent enough for
   the chosen model.
   Do **not** use `/login anthropic`: upstream says that route draws from
   extra usage and is billed per token, not against the plan.
2. `/login chatgpt-subscription`, browser login or device code for a
   headless machine. omo keeps its own token; it does not read
   `~/.codex/auth.json`.
3. `/model` to pick a model; Ctrl+S in the picker makes it the default.

Check:

```bash
omo auth check --provider anthropic-subscription
omo auth check --provider chatgpt-subscription
omo doctor
```

Tokens live in `~/.omo/agent/auth.json` (mode 0600), never in the repo.
`/logout` removes one.

## State and config

Everything is under `~/.omo`, not XDG: `agent/` holds `auth.json`,
`settings.json`, sessions and logs; `memory/` holds agent memory. None of
it is managed by home-manager. `settings.json` is rewritten by omo itself
(`/model`, `/settings`), and the migrations that run at startup rewrite
`~/.omo/omo.jsonc` and refuse a symlink, so neither is linked from the
repo. omo runs with no `omo.jsonc` at all.

omo reads `~/.claude/rules/` and, when there is no
`~/.config/opencode/AGENTS.md`, `~/.claude/CLAUDE.md` as global rules, so
the Claude Code instructions apply in its sessions too. On first launch it
runs an onboarding chat, and it asks before trusting a folder with
project-local settings or skills.

The package wrapper sets `OMO_SEND_ANONYMOUS_TELEMETRY=0`, which turns off
OmO's PostHog usage telemetry.

## Updates

llm-agents packages omo-ai from its npm `beta` tag, so any `lock.yml` run
that moves `llm-agents` can bring a new beta, and a new `claude-code`,
which the wrapper uses.

Remove: drop `home-omo` from `profiles/full.nix`, then delete `~/.omo`.
