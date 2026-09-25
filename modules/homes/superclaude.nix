# SuperClaude: 30 /sc:* slash commands and 20 persona agents for Claude
# Code. Upstream ships them as a pip package whose `superclaude install`
# only copies markdown into ~/.claude; the files are vendored from the
# tagged source instead, with no Python involved. Bump `version` and
# `hash` together.
#
# Each agent is linked on its own (recursive), so ~/.claude/agents stays a
# writable directory for agents added by hand.
{ ... }:
{
  den.aspects.home-superclaude.provides.to-users.homeManager =
    { pkgs, ... }:
    let
      version = "4.3.0";
      src = pkgs.fetchFromGitHub {
        owner = "SuperClaude-Org";
        repo = "SuperClaude_Framework";
        tag = "v${version}";
        hash = "sha256-hLcjJeIL5H76GYtH0KcNFUISBDzfmssHcL70dVnCBiY=";
      };
      # the upstream installer skips README.md for agents only; it is not a
      # command either
      files = pkgs.runCommand "superclaude-${version}" { } ''
        mkdir -p $out/commands $out/agents
        cp ${src}/src/superclaude/commands/*.md $out/commands/
        cp ${src}/src/superclaude/agents/*.md $out/agents/
        rm $out/commands/README.md $out/agents/README.md
      '';
    in
    {
      home.file.".claude/commands/sc".source = "${files}/commands";
      home.file.".claude/agents" = {
        source = "${files}/agents";
        recursive = true;
      };
    };
}
