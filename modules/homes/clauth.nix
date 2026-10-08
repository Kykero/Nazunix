# clauth: Claude Code (and Codex) multi-account manager. Switches the
# global login, runs `claude` under another account in its own
# CLAUDE_CONFIG_DIR (`clauth start`), watches 5h/7d usage and walks a
# fallback chain. Its herdr plugin opens the dashboard in a popup and tags
# each agent pane with the account it spends (docs/herdr.md).
#
# Packaged by llm-agents with the self-updater patched out, which also
# stops clauth from reinstalling its herdr plugin on its own: plugin
# updates are a manual `clauth herdr install`. Profiles and tokens live in
# ~/.clauth/ and never enter the repo. A switch rewrites
# ~/.claude/.credentials.json and the `env` block of settings.json, which
# is merged, not linked (claude-plugins.nix).
{ inputs, ... }:
{
  den.aspects.home-clauth.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.clauth ];
    };
}
