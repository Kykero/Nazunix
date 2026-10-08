{ den, ... }:
{
  # coding agents from llm-agents (numtide cache) and everything around them;
  # full-only, so the -base gateways never pull them during bootstrap
  den.aspects.profile-ai = {
    includes = [
      # agents and their desktop apps
      den.aspects.home-claude-code
      den.aspects.home-codex
      den.aspects.desktop-claude-app
      den.aspects.desktop-codex-app

      # multiplexers and what hangs off herdr
      den.aspects.home-herdr
      den.aspects.home-herdr-integrations
      den.aspects.home-omo
      den.aspects.home-omo-graph
      den.aspects.home-zoetrope
      den.aspects.home-collie
      den.aspects.home-clauth

      # Claude Code tooling: plugins, SuperClaude, MCP servers, rtk, graphify
      den.aspects.home-claude-plugins
      den.aspects.home-superclaude
      den.aspects.home-claude-mcp-context7
      den.aspects.home-claude-mcp-serena
      den.aspects.home-rtk
      den.aspects.home-graphify
    ];
  };
}
