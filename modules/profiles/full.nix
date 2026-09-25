{ den, ... }:
{
  den.aspects.profile-full = {
    includes = [
      den.aspects.profile-base
      den.aspects.profile-desktop

      # coding agents from llm-agents (numtide cache); kept off the -base
      # gateways so the bootstrap install never pulls them
      den.aspects.home-claude-code
      den.aspects.home-codex
      den.aspects.home-herdr
      den.aspects.home-zoetrope
      den.aspects.home-herdr-projects
      den.aspects.home-collie

      # Claude Code tooling: plugins, SuperClaude, MCP servers, rtk, graphify
      den.aspects.home-claude-plugins
    ];
  };
}
