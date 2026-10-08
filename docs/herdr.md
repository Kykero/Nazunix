# herdr and its plugins

[herdr](https://herdr.dev) is a terminal multiplexer for coding agents: panes,
tabs and sessions like tmux, plus a sidebar that knows which pane runs
`claude` or `codex` and whether it is working, idle or blocked. It runs inside
ghostty. Everything here is part of the `full` profile only.

What Nix provides, and what stays imperative:

| | Nix (repo) | By hand, once per machine |
|---|---|---|
| herdr | binary, `config.toml` (`homes/herdr.nix`), agent integrations (`homes/herdr-integrations.nix`) | nothing |
| zoetrope | `zoe`, the plugin linked, its key (`homes/zoetrope.nix`) | nothing |
| clauth | binary, the plugin linked, its key and sidebar tag (`homes/clauth.nix`) | profiles (`clauth capture`) |
| herdr-projects | binary, the plugin linked, its key, rows, hooks, skill, default profiles (`homes/herdr-projects.nix`); omo as coordinator (`homes/omo-pi.nix`) | nothing |
| Collie | `collie` binary (`homes/collie.nix`, flake input `collie`) | `.env`, `tailscale serve`, `collie start`, pairing |

## herdr's config

`~/.config/herdr/config.toml` is **owned by Nix**. It is generated from the
`herdr.settings` option, which every aspect can add to, checked with
`herdr config check` at build time, then copied (not linked) and rewritten
on every switch, and the running server reloads it. The theme is
`terminal`, which draws herdr's UI from the terminal's ANSI palette, so
herdr follows ghostty's Noctalia colours instead of a built-in palette.

A key or row a plugin's own setup step appends (`setup-keys`,
`clauth herdr install`) is lost at the next switch. Put it in
`herdr.settings` in that plugin's aspect instead.

Inside herdr, `prefix+shift+r` reloads the client side (sidebar rows).

## Plugins

The `herdr.plugins` option maps a plugin id to its folder in the store. On
every switch each one is registered with `herdr plugin link`, which works
without a running server and runs no build steps, so whatever a plugin
needs on `PATH` comes from its aspect. A plugin linked from the store and
no longer in the option is unlinked. `herdr plugin list` shows them as
`local:/nix/store/...`. Plugins installed by hand from GitHub are left
alone.

## Agent integrations

These let herdr learn each agent's state and session id (session restore,
zoetrope, clauth's pane tag). `homes/herdr-integrations.nix` runs
`herdr integration install claude` and `codex` on every switch, for each
agent whose folder exists; both are idempotent. They write hooks into
`~/.claude/settings.json` and `~/.codex/`, which is why neither agent is
configured through home-manager. An agent already running when the hook
lands never reports its session: start it again.

## zoetrope

Draws the focused agent's session as a live flow graph. Focus an agent
pane and press `prefix+shift+z`: the graph opens split beside the pane and
follows the session; the same key with the graph focused closes it. The
other placements stay actions:

```bash
herdr plugin action invoke open --plugin furkankly.zoetrope       # overlay
herdr plugin action invoke open-tab --plugin furkankly.zoetrope   # own tab
```

`zoe <id>` or `zoe <file>` also works on its own, and replays a finished
session. To upgrade, bump `version`, both binary hashes (the release's
`.sha512` files) and the source hash in `homes/zoetrope.nix`.

## herdr-projects

One coordinator agent hands the work out to worker threads: each thread
is an agent (Claude Code, Codex...) in its own pane, on its own git
worktree and branch (`hp/<project>/<id>-<title>`). Projects live in
`~/.herdr-projects/<name>/` (`PROJECT.md` with the goal and standing
instructions, `TASKS.md`, shared memory, thread reports). A ticker started
with the herdr server launches the threads and follows pull requests; a
merged pull request resolves its thread.

Everything `herdr-projects configure` does is in `homes/herdr-projects.nix`
instead: the plugin is linked from the release (source plus its static
binary), `prefix+shift+j` opens the popup, the tab bar counts what needs
you, the sidebar rows carry the thread state (`$hp_sub`), the progress
hooks are merged into `~/.claude/settings.json` and `~/.codex/hooks.json`,
and the autoproject skill is linked. Do not run `configure`: its edits to
herdr's config would not survive a switch. `herdr-projects update`
cannot replace the store binary; bump `version` and the hashes instead.

The defaults, merged into `~/.config/herdr-projects/config.toml` on every
switch (the rest of that file, safety and popup-made profiles, stays
herdr-projects'), are `coordinator_profile = "pi"` and
`thread_profile = "claude"`: the coordinator is OmO, through the `pi` on
`PATH` from `homes/omo-pi.nix` (herdr starts the `pi` kind by running
`pi`; omo takes pi's flags). A global rule in
`~/.claude/rules/herdr-projects-coordinator.md` tells the coordinator to
resolve a finished thread, which closes its worktree and workspace, and
how to bring one back.

```bash
herdr-projects new "Billing" --goal "Ship the billing page" --repo ~/dev/app
herdr-projects open billing --tab    # the coordinator, in the project's workspace
herdr-projects overview              # threads grouped by what needs you
herdr-projects doctor
```

Then tell the coordinator what you want. It proposes threads and waits
for a go (or `start_threads = "auto"`). `herdr-projects thread resolve`
closes a finished one, `thread restart` brings one back. Projects and
their state stay in `~/.herdr-projects/`, outside the repo.

Known limit: omo starts its own Claude Code with no user settings, so
herdr's hooks never fire there. herdr shows the coordinator pane as
`claude` and always `idle`, and the ticker may nudge it while it works.
The workers are real `claude` or `codex` panes and report normally.
`omo-graph` shows every session, the coordinator's included (docs/omo.md).

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

## clauth

Multi-account manager for Claude Code (and Codex): each logged-in account
becomes a profile, switched with `clauth <name>` or from its TUI, with live
5h/7d usage bars and a fallback chain that moves off an exhausted account.
`clauth start <name>` runs `claude` under another account in its own
`CLAUDE_CONFIG_DIR`, so two accounts can work side by side in herdr.

The herdr plugin is linked from the package's own source, so it always
matches the binary. `prefix+a` opens the dashboard in a popup, and every
claude or codex row in the sidebar ends with the account the pane spends.
An `omo` pane gets no tag: omo keeps its own sign-ins. Do not run
`clauth herdr install`: the Nix config already holds what it would
append, and its edit would not survive a switch.

The binary comes from `llm-agents` with the self-updater patched out;
updates come with `lock.yml`. Profiles and tokens live in `~/.clauth/`
(mode 0600), never in the repo. A switch rewrites
`~/.claude/.credentials.json` and the `env` block of
`~/.claude/settings.json`; the activation merges in `claude-plugins.nix`
and `rtk.nix` leave that block alone.

Once per machine, logged in to each account in turn:

```bash
clauth capture <name>      # snapshot the current Claude Code login
clauth login <name>        # or log a new account in directly
```

Optional: the Claude Code plugin (MCP tools `profiles`, `switch_profile`,
`delegate`, `monitor`) installs from the TUI's Services tab, `plugin` row,
`f`. Decline the offer to install shell completions on first launch: the
fish completions already come with the package, and fish's config is
read-only.
