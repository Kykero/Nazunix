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
# ~/.omo/agent/settings.json is omo's own state. The package wrapper sets
# OMO_SEND_ANONYMOUS_TELEMETRY=0 (PostHog off).
#
# omo reports itself to herdr as `pi` (working, done, blocked) from a
# built-in extension, but herdr also scans the pane's processes: omo's main
# process is titled `OmO`, which herdr does not know, while the Claude Code
# it runs for its Claude models is named `claude`, which herdr does. The
# two disagree, herdr drops omo's report and shows the pane as an idle
# `claude`. So omo runs its Claude Code through `omo-claude`: the same
# llm-agents claude-code wrapper, exec'd under that name, which herdr does
# not recognize, leaving omo's own report in charge.
{ inputs, ... }:
{
  den.aspects.home-omo.provides.to-users.homeManager =
    { pkgs, ... }:
    let
      agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      omoClaude = pkgs.runCommand "omo-claude" { } ''
        mkdir -p $out/bin
        substitute ${agents.claude-code}/bin/claude $out/bin/omo-claude \
          --replace-fail 'exec -a "claude"' 'exec -a "omo-claude"'
        chmod +x $out/bin/omo-claude
      '';
      omo = pkgs.writeShellScriptBin "omo" ''
        export CLAUDE_CODE_EXECUTABLE=${omoClaude}/bin/omo-claude
        exec ${agents.omo-ai}/bin/omo "$@"
      '';
    in
    {
      home.packages = [ omo ];
    };
}
