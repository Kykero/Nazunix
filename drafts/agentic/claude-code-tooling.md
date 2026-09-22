# Draft — Claude Code tooling inventory (pre-reinstall snapshot, 2026-09-22)

Snapshot of the Claude Code setup on the Windows dev machine, taken before a
wipe. Purpose: recreate the same environment on Nazunix (`nazuna` home) and
decide what becomes declarative (Home Manager) versus what stays imperative.
Nothing here is evaluated. Companion to `herdr-claude-multi-account*.md`,
which covers the `claude-code` package, wrapper and multi-account isolation.

## 1. What was installed

| Layer | Thing | Version / pin | Install channel | Wired into Claude? |
| --- | --- | --- | --- | --- |
| Runtime | Claude Code CLI | 2.1.278 | native binary, `autoUpdatesChannel = latest` | — |
| Plugin | superpowers (obra) | 6.3.0 | marketplace `claude-plugins-official` | yes, `enabledPlugins` |
| Plugin | caveman (JuliusBrussee) | commit `0d95a81` | extra marketplace `caveman` | yes, `enabledPlugins` |
| Framework | SuperClaude | 4.3.0 | `pip install superclaude` + `superclaude install` | yes, 31 `/sc:*` commands + 20 agents |
| MCP | serena (oraios) | git HEAD | `uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project <path>` | yes, user scope |
| MCP | context7 (upstash) | npx latest | `npx -y @upstash/context7-mcp` | yes, user scope |
| CLI | rtk (rtk-ai) | 0.43.0 | binary in `~/.local/bin` | **no** — never ran `rtk init`, no hooks in settings |
| Skill | graphify (Graphify-Labs) | pip `graphifyy` 0.9.53 | `pip install graphifyy` | **no** — `graphify install --platform claude` never run |
| Skill | data-storytelling | — | symlink to `~/.agents/skills/…` (target empty) | dead symlink, drop |
| Skill | OpenSwarm leftovers (`app_builder_skill.md`, `swarm_debug_skill.md`) | `@vrsen/openswarm` 0.1.27 (npm -g) | pulled in by openswarm | stray files, drop |
| Skill | clockify-worklog | — | hand-written | **deleted 2026-09-22**, not carried over |

Global `settings.json` (user scope), minus theme/notification noise:

```json
{
  "model": "claude-fable-5-1[1m]",
  "effortLevel": "high",
  "autoUpdatesChannel": "latest",
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true,
    "caveman@caveman": true
  },
  "extraKnownMarketplaces": {
    "caveman": { "source": { "source": "github", "repo": "JuliusBrussee/caveman" } }
  },
  "skipDangerousModePermissionPrompt": true,
  "skipWorkflowUsageWarning": true
}
```

No global `CLAUDE.md`, no hooks, no `settings.local.json` worth keeping
(one PowerShell permission). Per-project memory lives under
`~/.claude/projects/<slug>/memory/` and is backed up separately; it is not
part of this note.

## 2. Each piece in one paragraph

**superpowers** — process skills (brainstorming, systematic-debugging, TDD,
writing-plans, subagent-driven-development, verification-before-completion).
Its `using-superpowers` skill is injected at session start and makes skill
invocation mandatory. Source: <https://github.com/obra/superpowers>.

**caveman** — terse output mode (`/caveman lite|full|ultra`), plus
`cavecrew-*` subagents with compressed output and a statusline badge
(never configured). Source: <https://github.com/JuliusBrussee/caveman>.

**SuperClaude** — Python package that copies 31 slash commands into
`~/.claude/commands/sc/` and 20 persona agents into `~/.claude/agents/`
(architects, python-expert, root-cause-analyst, deep-research, pm-agent…).
Pure file drop, no daemon. Source: <https://github.com/SuperClaude-Org/SuperClaude_Framework>.

**serena** — LSP-backed MCP server (symbols, references, semantic edits,
project memories). Launched through `uvx` from git, so it re-resolves on
every start; the `--project` flag hard-codes one project path, which is
the wrong shape for a multi-project machine (see §4).
Source: <https://github.com/oraios/serena>.

**context7** — documentation MCP. `CLAUDE.md` of this repo already lists the
library IDs to query (`/denful/den`, `/nixos/nix`, …).
Source: <https://github.com/upstash/context7>.

**rtk** — "Rust Token Killer": CLI proxy that rewrites `git`, `ls`, `find`,
`test`, `docker`… output into compact form before it hits the model. Meant
to be wired with `rtk init`, which adds a PreToolUse hook rewriting Bash
commands. Was installed but never wired. Source: <https://github.com/rtk-ai/rtk>.

**graphify** — turns a folder (code, docs, PDFs, images) into a knowledge
graph (`graphify-out/graph.json`) queryable from a skill (`/graphify`,
`graphify path`, `graphify explain`). pip package is `graphifyy`; the skill is
installed per platform with `graphify install`. Was installed but never
wired. Source: <https://github.com/Graphify-Labs/graphify>.

## 3. Target on Nazunix — what goes where

Split by "who owns the file":

| Piece | Declarative (HM) | Imperative | Notes |
| --- | --- | --- | --- |
| Claude Code binary | `home.packages` via `llm-agents` input (see herdr draft) | — | wrapper `claude` + `claude-a`/`claude-b` |
| `settings.json` | `home.file` → `~/.claude/settings.json` | — | Claude rewrites this file at runtime (plugin state); a read-only symlink may break `/plugin` and `/config`. Test in phase 7, fall back to `home.activation` copy-if-missing. |
| `~/.claude.json` (MCP servers) | **no** | `claude mcp add -s user …` ×2 | file is mostly runtime state and OAuth; do not manage it |
| superpowers, caveman | via `settings.json` `enabledPlugins` + `extraKnownMarketplaces` | first launch downloads them | nothing to package |
| SuperClaude | `home.packages` with `python3.withPackages` or a `uv tool` wrapper | `superclaude install` once | outputs are plain markdown; alternative: vendor the 51 files into `home.file` and skip the pip package entirely |
| serena | — | `claude mcp add -s user serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant` | drop `--project`; serena picks the cwd. `uv` must be in `home.packages`. |
| context7 | — | `claude mcp add -s user context7 -- npx -y @upstash/context7-mcp` | `nodejs` in `home.packages` |
| rtk | `home.packages` (nixpkgs `rtk` if present, else `rustPlatform.buildRustPackage`) | `rtk init` per machine | decide first whether to adopt it at all (§4) |
| graphify | `home.packages` (`python3Packages.buildPythonApplication` from PyPI `graphifyy`) | `graphify install --platform claude` | or vendor the skill file into `home.file` under `~/.claude/skills/graphify/` |
| memory dirs | — | restore from backup into `~/.claude/projects/<slug>/memory/` | slugs encode the absolute project path, so they change between OS; rename dirs after restore |

## 4. Open decisions

- **rtk: adopt or drop.** Installed for months, never wired, so it has
  proven nothing. Either run `rtk init` on Nazunix and measure with
  `rtk gain`, or remove the line. Interaction with the `claude` wrapper and
  with caveman (both compress output) is unknown.
- **graphify: same question.** Zero graphs ever built. Try it once on this
  repo (`graphify .`) before packaging anything.
- **serena `--project` flag.** Current config pins one project; on Nazunix
  the server must be project-agnostic. Verify `--context ide-assistant`
  without `--project` still activates on cwd.
- **SuperClaude as pip vs vendored files.** Vendoring is more Nix-native and
  removes a Python dependency, but loses `superclaude install --force`
  updates. Lean vendoring, revisit if upstream ships non-markdown parts.
- **`settings.json` ownership.** See §3; blocked until a machine exists
  (roadmap phase 7).
- **Drop for good:** data-storytelling symlink, OpenSwarm skill files,
  `@vrsen/openswarm` npm global, clockify-worklog (already deleted).
