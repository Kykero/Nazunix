# herdr and its plugins

[herdr](https://herdr.dev) is a terminal multiplexer for coding agents: panes,
tabs and sessions like tmux, plus a sidebar that knows which pane runs
`claude` or `codex` and whether it is working, idle or blocked. It runs inside
ghostty. Everything here is part of the `full` profile only.

What Nix provides, and what stays imperative:

| | Nix (repo) | By hand, once per machine |
|---|---|---|
| herdr | binary (`homes/herdr.nix`), seed `config.toml` | agent integrations |
| herdr-projects | `~/.local/bin` on `PATH` (`homes/herdr-projects.nix`) | plugin install, CLI link, `configure` |
| zoetrope | `zoe` binary (`homes/zoetrope.nix`) | plugin install, `setup-keys` |
| Collie | `collie` binary (`homes/collie.nix`, flake input `collie`) | `.env`, `tailscale serve`, `collie start`, pairing |

## herdr's config

`~/.config/herdr/config.toml` is **seeded, not linked**. On activation,
home-manager writes it only if it is missing, with onboarding skipped and
`theme.name = "terminal"`. That theme draws herdr's UI from the terminal's
ANSI palette, so herdr follows ghostty's Noctalia colours instead of a
built-in palette. After that the file is yours and the plugins': they add
their keys and sidebar rows to it, and home-manager never overwrites it.

To start over from the seed: delete the file and rebuild. Useful commands:

```bash
herdr config check             # validate the file
herdr server reload-config     # apply it to the running server
```

Inside herdr, `prefix+shift+r` reloads the client side (sidebar rows).

## Agent integrations

These let herdr learn each agent's session id (needed for session restore
and for zoetrope):

```bash
herdr integration install claude
herdr integration install codex
```

They write hooks into `~/.claude/settings.json` and `~/.codex/`, which
is why neither agent is configured through home-manager.

## herdr-projects

### What it is

You talk to one agent, the **coordinator**. It doesn't do any of the work
itself. It splits what you ask for into **threads**, and each thread is a
separate agent (Claude Code, Codex, ...) with its own git worktree and branch
(`hp/<project>/<id>-<title>`), or a tab when the task has no repository.
Each thread starts from a brief with the project's goal, your standing
instructions, the shared memory and its own task. You don't brief each agent
by hand anymore; you answer the ones that need you.

A **project** is a folder, `~/.herdr-projects/<name>/`:

| File | Role |
|---|---|
| `PROJECT.md` | goal, repos, settings, standing instructions |
| `AGENTS.md` (+ `CLAUDE.md` link) | tells the agent started there that it is the coordinator |
| `MEMORY.md`, `memory/` | shared memory; a thread's `## Remember` section flows back here |
| `TASKS.md` | task list the coordinator keeps |
| `threads/` | one record and report per thread |
| `library/`, `uploads/` | files threads produced, files you hand them |

The safety settings live in `~/.config/herdr-projects/config.toml`, outside
any project folder, where no agent works.

What you see in herdr:

- **Sidebar**: each thread as `t-0003 · <title>`, with a state line:
  `needs you` (red), `review · PR #4` (yellow), `working · ~40%`,
  `working · 12m quiet`, `landing`, `idle`. Under it, the agent's own
  activity line. The project's row sums it up (`2 need you · 3 working`),
  and the list is sorted so whatever needs you comes first.
- **Tab bar**: `projects: N need you`.
- **Popup** (`prefix+a`): threads, tasks, inbox, routines, settings,
  memory. Each thread report ends with a `## Next` list: press its number to
  send that line back to the thread.
- **Notifications** that name the project and the thread.

A background **ticker** starts the thread agents (one per project about
every 15 s) and follows pull requests. A failing check or a review comment
goes back to the thread (the `pr-followup` routine). A merged PR resolves
the thread and removes its worktree, workspace and branch. The report is
always kept. The plugin never merges or pushes by itself; a merge happens
when you send the thread its "Merge the PR" line.

Safety is soft by default. The coordinator proposes threads and waits for
your go-ahead (or `start_threads = "auto"`). Thread agents keep their normal
permission prompts. Routines can't run shell commands until you enable them
and approve each command. An agent running with permissions skipped can
still edit all of this.

### Install

Needs herdr 0.9.1 or newer, both client and running server (`herdr status`).

```bash
herdr plugin install eliasstravik/herdr-projects
herdr plugin list                                   # prints the plugin's folder
ln -s <plugin folder>/target/release/herdr-projects ~/.local/bin/herdr-projects
herdr-projects doctor
herdr-projects configure --dry-run
herdr-projects configure
```

The install downloads the release's static (musl) binary and checks it
against `SHA256SUMS`, so no Rust toolchain is needed. `configure` adds the
two agent rows (`$hp_state`, `$hp_activity`), the Space row (`$hp`), the
popup key `prefix+a` and the tab-bar entry to herdr's config. It also adds
progress hooks to `~/.claude/settings.json` and `~/.codex/hooks.json`.
Every edit is journaled, so `herdr-projects unconfigure` removes exactly
what it added.

Optional: `gh` (logged in) for PR follow-up, `ssh`/`rsync` for threads on
other machines. Neither is installed by the repo.

### Use

```bash
herdr-projects new "Billing" --goal "Ship the billing page" --repo ~/dev/app
herdr-projects open billing          # coordinator in this pane (--tab, --agent codex, --new)
```

Or, from herdr: `herdr plugin action invoke new --plugin herdr-projects`.
Then tell the coordinator what you want in its pane. It restates the goal,
proposes threads and starts the ones you name (or "all"). New worktrees
start on the agent's folder-trust prompt, so a fresh thread shows
`needs you` until you answer it in its pane.

Other entry points:

- `herdr-projects thread start`: start a thread yourself.
- `herdr-projects thread adopt`: turn an agent pane you already have into a
  thread.
- `herdr-projects adopt-workspace`: turn the current workspace into a
  project, with its agent as the first thread.

Allow-list the binary in your agent **by subcommand, never bare**.
Reading and steering are fine (`skill`, `context`, `report`, `inbox done`,
`thread list`, `thread prompt`, `thread next`). Leave `thread resolve`,
`sweep`, `delete`, `routine approve`, `configure` and `thread start` on the
normal prompt.

### Maintain

```bash
herdr-projects doctor [--fix]       # setup check; --fix repairs the plugin's own files
herdr-projects ticker status
herdr-projects update [--check]     # new binary, doctor --fix, ticker restart
```

Remove: `herdr-projects unconfigure`, `herdr-projects ticker stop`,
`herdr plugin uninstall herdr-projects`. Projects stay in `~/.herdr-projects/`.

## zoetrope

Draws the focused agent's session as a live flow graph. `zoe` comes from
the repo, so the plugin's install step finds it and installs nothing.

```bash
herdr plugin install furkankly/zoetrope/herdr-plugin
herdr plugin action invoke setup-keys --plugin furkankly.zoetrope
```

Focus an agent pane and press `prefix+shift+z`: the graph opens over the
pane and follows the session. The same key closes it. `setup-keys` also
writes the split (`prefix+shift+v`) and tab (`prefix+shift+c`) placements
into the config as comments. Requires the agent integrations above.

To upgrade `zoe`, bump `version` and both hashes in `homes/zoetrope.nix`
(from the release's `.sha512` files).

## Collie

A phone web app (PWA) for the herd: which agents need you, replies from the
phone keyboard (dictation works), Esc/Ctrl-C/arrows keypad, push
notifications, file attachments. It is **remote shell access by design**.
The bridge listens on `127.0.0.1:8787`, and `tailscale serve` exposes it on
the tailnet with HTTPS and the caller's identity. Read upstream's
`docs/security.md` before turning it on.

Collie runs standalone (the `collie` on `PATH`), not as a herdr plugin, and
still mirrors herdr. Once per machine:

1. Enable HTTPS for the tailnet (Tailscale admin console, DNS page).
2. Let the user drive `tailscale serve` without sudo:
   `sudo tailscale set --operator=$USER`.
3. Create `~/.config/collie/.env` with `COLLIE_TRUSTED_USER=<your tailnet
   login>`. This file is private and never goes in the repo. Without it, any
   device on the tailnet gets write access, and the bridge says so.
4. With herdr running: `collie start`. It writes the `systemd --user` unit
   and the serve mapping, then prints the URL.
5. `collie pair` on the machine, then scan the QR code with the phone and add
   the page to the home screen. Pairing is the write credential.

`collie status` and `collie doctor` check the install. `collie push-keys`
then `collie restart` turns on push notifications.

**After a rebuild that changes Collie** (a `lock.yml` run), run
`collie restart`. `collie start` bakes the store path into the systemd unit,
so the service keeps running the old version until then, and it breaks
once that path is garbage-collected. `collie update` declines on this
install on purpose.

Remove: `collie uninstall` (stops the service, removes the unit and the
serve mapping). State stays in `~/.local/state/collie/`.
