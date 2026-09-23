# Claude desktop app (chat and Claude Code sessions) from llm-agents
# (numtide): Anthropic's prebuilt Linux release, repackaged, nothing to
# compile. Its unfree licence is llm-agents' own, which evaluates without
# allowUnfree. The desktop entry registers x-scheme-handler/claude for the
# OAuth sign-in with the subscription.
{ inputs, ... }:
{
  den.aspects.desktop-claude-app.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop ];
    };
}
