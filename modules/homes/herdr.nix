# herdr: terminal multiplexer for coding agents. It runs the real `claude`
# and `codex` found on PATH and tells which panes are working or blocked.
# Session restore is an imperative, per-machine step:
#   herdr integration install claude
#   herdr integration install codex
{ inputs, ... }:
{
  den.aspects.home-herdr.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr ];
    };
}
