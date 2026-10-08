# Codex CLI from llm-agents (numtide), signed in with the ChatGPT
# subscription (`codex login`, state in ~/.codex/auth.json, never in the
# repo). A plain package, not programs.codex: herdr's integration writes
# ~/.codex/{config.toml,hooks.json}. Built from source upstream, so it
# must come from cache.numtide.com (nix/caches.nix).
{ inputs, ... }:
{
  den.aspects.home-codex.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex ];
    };
}
