# herdr: terminal multiplexer for coding agents. It runs the real `claude`
# and `codex` found on PATH and tells which panes are working or blocked.
# Integrations and plugins are imperative, per-machine steps
# (docs/herdr.md).
#
# config.toml is seeded, not linked: plugins (herdr-projects `configure`,
# zoetrope `setup-keys`) edit it in place, and herdr-projects refuses a
# symlink. The seed is written only when the file is missing (or is still
# the read-only link of an earlier generation) and is never overwritten. It
# skips onboarding and picks the `terminal` theme, which draws herdr's UI
# from the host terminal's ANSI palette, i.e. ghostty's Noctalia colours
# (terminal.nix).
{ inputs, ... }:
{
  den.aspects.home-herdr.provides.to-users.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      seed = (pkgs.formats.toml { }).generate "herdr-config.toml" {
        onboarding = false;
        theme.name = "terminal";
      };
    in
    {
      home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr ];

      home.activation.herdrConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        cfg="${config.xdg.configHome}/herdr/config.toml"
        if [ ! -e "$cfg" ] || [ -L "$cfg" ]; then
          run mkdir -p "$(dirname "$cfg")"
          run rm -f "$cfg"
          run install -m 644 ${seed} "$cfg"
        fi
      '';
    };
}
