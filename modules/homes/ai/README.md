# AI: coding agents and everything around them

The coding agents (Claude Code, Codex, OmO), the herdr multiplexer that runs
them, its plugins, and the Claude Code tooling. Every aspect here is listed in
`den.aspects.profile-ai` ([`profiles/ai.nix`](../../profiles/ai.nix)), which
only the `full` profile includes, so the `-base` gateways never pull any of it
during bootstrap. Most packages come from the `llm-agents` flake input
(numtide cache).

## Files

| File | Aspect | What it does |
|---|---|---|
| `claude-code.nix` | `home-claude-code` | Claude Code CLI, a plain package (not `programs.claude-code`) |
| `codex.nix` | `home-codex` | Codex CLI, a plain package (not `programs.codex`) |
| `claude-app.nix` | `desktop-claude-app` | Claude desktop app, wrapped to keep its tokens in gnome-keyring |
| `codex-app.nix` | `desktop-codex-app` | ChatGPT/Codex desktop app, same keyring wrapper |
| `claude-plugins.nix` | `home-claude-plugins` | enables the superpowers and caveman plugins in `~/.claude/settings.json` |
| `superclaude.nix` | `home-superclaude` | SuperClaude `/sc:*` commands and persona agents, vendored from the tagged source |
| `claude-mcp-context7.nix` | `home-claude-mcp-context7` | context7 MCP server (library docs), from nixpkgs |
| `claude-mcp-serena.nix` | `home-claude-mcp-serena` | serena MCP server (LSP symbol lookup and edits), run through `uvx` at a pinned tag |
| `rtk.nix` | `home-rtk` | rtk PreToolUse hook that compacts Bash output; `RTK.md` imported by the global `CLAUDE.md` |
| `graphify.nix` | `home-graphify` | graphify and its `/graphify` skill for Claude Code |
| `clauth.nix` | `home-clauth` | multi-account manager for Claude Code and Codex, plus its herdr plugin |
| `herdr.nix` | `home-herdr` | herdr itself; defines the `herdr.settings` and `herdr.plugins` options |
| `herdr-integrations.nix` | `home-herdr-integrations` | `herdr integration install claude` and `codex` on every switch |
| `zoetrope.nix` | `home-zoetrope` | `zoe` (live session flow graph) and its herdr plugin |
| `herdr-projects.nix` | `home-herdr-projects` | coordinator/worker threads plugin, everything `configure` would do |
| `omo.nix` | `home-omo` | OmO (`omo`), with its Claude Code renamed `omo-claude` |
| `omo-pi.nix` | `home-omo-pi` | a `pi` that execs `omo`, so OmO is herdr-projects' coordinator |
| `omo-graph.nix`, `omo-graph.sh` | `home-omo-graph` | `omo-graph`: pick any live agent session and watch it in `zoe` |
| `collie.nix` | `home-collie` | Collie, the phone web app for the agents in herdr, and its herdr plugin |

## How the pieces fit

- **Agents.** `claude` and `codex` are the CLIs; herdr runs the real ones
  found on `PATH`. Neither is configured through home-manager, because herdr's
  integration (and `/plugin`, clauth, herdr-projects) write to their settings
  at runtime.
- **Claude Code tooling.** Several aspects edit the same files without owning
  them. `~/.claude/settings.json` is merged by activation scripts, each
  touching only its own keys: plugins (`claude-plugins.nix`), the rtk hook
  (`rtk.nix`), herdr's session hook (`herdr-integrations.nix`) and
  herdr-projects' progress hooks (`herdr-projects.nix`, which runs after the
  other three). The MCP servers set one key each under `mcpServers` in
  `~/.claude.json`, which is what `claude mcp add -s user` would do.
  `~/.claude/CLAUDE.md` is linked, built from the lines `rtk.nix` and
  `graphify.nix` contribute.
- **herdr as the hub.** Any aspect can add to `herdr.settings` (becomes
  herdr's `config.toml`, Nix-owned, checked at build time) and
  `herdr.plugins` (linked with `herdr plugin link` on every switch). The
  plugins linked this way are zoetrope, clauth, herdr-projects and Collie. Keys:
  `prefix+a` clauth, `prefix+shift+z` zoetrope, `prefix+shift+j`
  herdr-projects.
- **Accounts.** clauth turns each logged-in Claude account into a profile,
  with 5h/7d usage bars and a fallback chain off an exhausted account.
  `clauth start <name>` runs `claude` under another account in its own
  `CLAUDE_CONFIG_DIR`, so two accounts can work side by side. Every claude
  and codex row in herdr's sidebar ends with the `$clauth` account tag.
- **Coordinator.** herdr-projects' defaults are `coordinator_profile = "pi"`
  and `thread_profile = "claude"`. herdr starts the `pi` kind by running
  `pi`, and `omo-pi.nix` puts a `pi` on `PATH` that execs `omo`, so the
  coordinator is OmO and the workers are Claude Code. The coordinator's
  standing rule is global, in `~/.claude/rules/herdr-projects-coordinator.md`.
- **OmO.** `omo.nix` runs omo's Claude Code as `omo-claude`, so herdr keeps
  omo's own `pi` report instead of showing an idle `claude`. herdr never
  learns omo's session ids; `omo-graph` finds them on the child command lines
  and lists them with herdr's own claude and codex sessions.
- **Desktop apps.** `claude-desktop` and `chatgpt` sit outside herdr. Both
  are Electron apps that do not recognise niri as a desktop, so they are told
  to use gnome-keyring, or their OAuth tokens are lost on exit.

## A typical session

1. Open ghostty and start `herdr`. Its theme follows the terminal palette.
2. Open panes running `claude` or `codex`. The sidebar shows each agent as
   working, idle or blocked, with the account it spends.
3. To work on several accounts, `prefix+a` opens the clauth dashboard (switch
   the global login, watch usage), or `clauth start <name>` opens a pane on
   another account.
4. For larger work, `herdr-projects new ...` then
   `herdr-projects open <project> --tab` (or `prefix+shift+j`) opens the OmO
   coordinator. It proposes threads, each a `claude` pane on its own worktree
   and branch; the tab bar counts what needs you, and `$hp_sub` in the
   sidebar carries each thread's state.
5. Watch a session with `prefix+shift+z` (zoetrope split on the focused claude
   or codex pane), or `omo-graph` in any pane for every live session,
   omo's Claude children included.
6. Away from the desk, Collie on the phone shows which agents need you and
   takes replies.

## Nix-owned vs by hand

Nix provides every binary, herdr's config and plugin links, the agent hooks,
the plugins and MCP entries, the SuperClaude, graphify and autoproject skill
files, and herdr-projects' default profiles. Do not run the setup steps that
would duplicate it (`herdr-projects configure`, `clauth herdr install`,
`rtk init -g`, `graphify install`): their edits would not survive a switch.

Done once per machine, by hand, and never in the repo:

- `claude` then `/login`, and `codex login` (subscriptions).
- `clauth capture <name>` or `clauth login <name>` for each Claude account.
- `clauth login <name> --codex` to adopt the Codex login, so clauth shows its
  5h/7d usage and tags codex panes.
- In `omo`: `/login anthropic-subscription` (not `/login anthropic`, billed
  per token), `/login chatgpt-subscription`, `/model`.
- Signing in to the desktop apps.
- Collie: tailnet HTTPS, `.env` in `herdr plugin config-dir herdr.collie`,
  its `start` action, `collie pair`.

Tokens and state stay in `~/.claude`, `~/.codex`, `~/.clauth`, `~/.omo`,
`~/.herdr-projects` and `~/.config/herdr/plugins/config/herdr.collie`.

## Details

- [docs/herdr.md](../../../docs/herdr.md): herdr's config, plugins,
  integrations, zoetrope, herdr-projects, Collie, clauth.
- [docs/omo.md](../../../docs/omo.md): OmO sign-in, state, coordinator role,
  session graph, updates.
