# herdr's agent integrations: a SessionStart hook that reports each
# agent's native session id to herdr (session restore, zoetrope, omo-graph,
# clauth's pane tag). Working/idle/blocked does not come from it: herdr
# reads that from the agent's process and screen.
#
# `herdr integration install` writes a hook script under ~/.claude/hooks
# (or ~/.codex) and merges it into the agent's settings; it runs on every
# switch. ~/.codex is created first, since nothing else does before the
# first `codex login` and herdr refuses to install without it. A failed
# install only warns. ~/.claude/settings.json stays a merged file
# (claude-plugins.nix).
#
# The hook scripts are `sh` handing over to `python3` from PATH; without it
# every hook fails quietly and herdr never learns a session id, so python3
# is on PATH here.
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
        run mkdir -p "${home}/.claude" "${home}/.codex"
        for agent in claude codex; do
          run ${herdr} integration install "$agent" >/dev/null 2>&1 \
            || warnEcho "herdr: $agent integration not installed, retried next switch"
        done
      '';
    };
}
