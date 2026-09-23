# Claude Code from llm-agents (numtide), signed in with the subscription
# (`claude` then /login, OAuth kept in ~/.claude.json, never in the repo).
# The package wrapper disables the auto-updater but keeps telemetry on,
# which Remote Control needs. A plain package, not programs.claude-code:
# herdr's integration writes hooks into ~/.claude/settings.json.
{ inputs, ... }:
{
  den.aspects.home-claude-code.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code ];
    };
}
