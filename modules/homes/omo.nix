# OmO standalone (omo-ai from llm-agents, binary `omo`): the OMO plugin on
# the senpi engine, a fork of pi. On trial alongside herdr, which stays:
# omo shows one session per TUI, with no view of which agents need you.
# Sign-ins happen inside the TUI, never in the repo (docs/omo.md): Claude
# through `/login anthropic-subscription` (never `/login anthropic`, billed
# per token), ChatGPT through `/login chatgpt-subscription`. Tokens land in
# ~/.omo/agent/auth.json.
#
# No config is managed. omo runs without ~/.omo/omo.jsonc, its startup
# migrations rewrite that file and refuse a symlink, and
# ~/.omo/agent/settings.json is omo's own state. The package wrapper points
# CLAUDE_CODE_EXECUTABLE at the same llm-agents claude-code as
# claude-code.nix and sets OMO_SEND_ANONYMOUS_TELEMETRY=0 (PostHog off).
{ inputs, ... }:
{
  den.aspects.home-omo.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omo-ai ];
    };
}
