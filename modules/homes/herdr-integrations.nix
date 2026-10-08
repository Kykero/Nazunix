# herdr's agent integrations: hooks that tell herdr each agent's state and
# native session id (session restore, zoetrope, clauth's pane tag).
# `herdr integration install` copies a hook script under ~/.claude/hooks
# (or ~/.codex) and merges it into the agent's settings. It is idempotent
# and writes only on change, so it simply runs on every switch, for each
# agent whose folder exists. ~/.claude/settings.json stays a merged file
# (claude-plugins.nix).
#
# The hook scripts are `sh` handing over to `python3` from PATH; without it
# every hook fails quietly and herdr never sees a state change or a session
# id, so python3 is on PATH here.
{ inputs, ... }:
{
  den.aspects.home-herdr-integrations.provides.to-users.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      herdr = "${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr}/bin/herdr";
      home = config.home.homeDirectory;
    in
    {
      home.packages = [ pkgs.python3 ];

      home.activation.herdrIntegrations = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        [ -d "${home}/.claude" ] && run ${herdr} integration install claude >/dev/null
        [ -d "${home}/.codex" ] && run ${herdr} integration install codex >/dev/null
        true
      '';
    };
}
