# drafts/agentic — agentic tooling for the `nazuna` home

Working notes for everything that runs, drives or supports LLM agents on the
fleet: the agent runtimes themselves, their orchestration layer, and the
forge CLIs the agents call. Nothing here is evaluated; CI is the only judge.
When a note graduates into `modules/homes/` or `modules/apps/`, delete it here.

| Note | Covers | Status |
| --- | --- | --- |
| `herdr-claude-multi-account.md` | original handoff v1 (French) | superseded in parts, kept for context |
| `herdr-claude-multi-account-review.md` | handoff v2 confronted to the repo at `e6f0762` | reference for a second Claude account (`claude-a`/`claude-b`), not implemented |
| `gh.md` | GitHub CLI: package, auth, what agents need from it | ready to implement in phase 7 |
| `glab.md` | GitLab CLI: package, auth, self-hosted host handling | ready to implement in phase 7 |

Graduated: `llm-agents` input and numtide cache (`flake.nix`,
`modules/nix/caches.nix`), `claude-code`, `codex` and `herdr` as one aspect
each in `modules/homes/`, single account per runtime. Claude Code tooling
(was `claude-code-tooling.md`): superpowers and caveman plugins,
SuperClaude, context7 and serena MCP servers, rtk and graphify, one aspect
each in `modules/homes/`.

## Shared constraints

- **Packages come from two inputs.** Ordinary CLIs (`gh`, `glab`, `uv`,
  `nodejs`) from `nixpkgs`. Agent runtimes (`claude-code`, `codex`, `herdr`)
  from `github:numtide/llm-agents.nix`, without `follows` (see
  `llm-agents.md` §2 for why). One aspect per tool, dendritic style.
- **Auth is never in the repo.** `gh` and `glab` keep tokens in their own
  stores; Claude keeps OAuth in `~/.claude.json`. Until sops-nix lands
  (roadmap), auth is a manual post-install step, listed per note.
- **Agents call the forge CLIs, so both must be on `PATH` for `claude` and
  `codex` running under herdr**, not only in an interactive shell. Put
  them in `home.packages`, not in a shell-only `programs.*`.
- **Not carried over from Windows:** the OpenAI Codex *app* (`gpt-6-astra`,
  computer-use plugins). Its output folder and state were wiped 2026-09-22.
  The Codex *CLI* is back as a second runtime from `llm-agents.nix`
  (`modules/homes/codex.nix`), with a single account.
