# clauth: Claude Code (and Codex) multi-account manager. Switches the
# global login, runs `claude` under another account in its own
# CLAUDE_CONFIG_DIR (`clauth start`), watches 5h/7d usage and walks a
# fallback chain (docs/herdr.md).
#
# Packaged by llm-agents with the self-updater patched out, which also
# stops clauth from reinstalling its herdr plugin on its own. The plugin is
# linked from the package's own source instead, so it always matches the
# binary, and what `clauth herdr install` would append to herdr's config
# (the popup key, the `$clauth` account tag in the agent rows) is set here.
# The key is prefix+shift+a: plain prefix+a is herdr-projects' popup.
#
# Profiles and tokens live in ~/.clauth/ and never enter the repo. A switch
# rewrites ~/.claude/.credentials.json and the `env` block of
# settings.json, which is merged, not linked (claude-plugins.nix).
{ inputs, ... }:
{
  den.aspects.home-clauth.provides.to-users.homeManager =
    { pkgs, ... }:
    let
      clauth = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.clauth;
      row = [
        [
          "state_icon"
          "workspace"
          "tab"
        ]
        [ "terminal_title_stripped" ]
        [
          "agent"
          "$clauth"
        ]
      ];
    in
    {
      home.packages = [ clauth ];

      herdr.plugins.clauth = "${clauth.src}/herdr-plugin";
      herdr.settings = {
        keys.command = [
          {
            key = "prefix+shift+a";
            type = "plugin_action";
            command = "clauth.open";
            description = "clauth accounts";
          }
        ];
        ui.sidebar.agents.rows_by_agent = {
          claude = row;
          codex = row;
        };
      };
    };
}
