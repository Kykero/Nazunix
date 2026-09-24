# herdr: terminal multiplexer for coding agents. It runs the real `claude`
# and `codex` found on PATH and tells which panes are working or blocked.
# Session restore is an imperative, per-machine step:
#   herdr integration install claude
#   herdr integration install codex
#
# The `terminal` theme draws herdr's UI from the host terminal's ANSI
# palette, i.e. ghostty's Noctalia colours (terminal.nix), instead of a
# built-in palette. herdr only writes its config when onboarding ends
# (`onboarding = false`); that line is set here, so the read-only file is
# never touched.
{ inputs, ... }:
{
  den.aspects.home-herdr.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr ];

      xdg.configFile."herdr/config.toml".source = (pkgs.formats.toml { }).generate "herdr-config.toml" {
        onboarding = false;
        theme.name = "terminal";
      };
    };
}
