# OpenAI's desktop app for ChatGPT and Codex, from llm-agents (numtide):
# the prebuilt release, repackaged, signed in with the ChatGPT
# subscription. Its wrapper turns on native Wayland from NIXOS_OZONE_WL
# (niri.nix). Unfree under llm-agents' own licence, no allowUnfree needed.
{ inputs, ... }:
{
  den.aspects.desktop-codex-app.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.chatgpt ];
    };
}
