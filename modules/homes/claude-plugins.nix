# Claude Code plugins: superpowers (process skills: brainstorming,
# systematic debugging, TDD, plans) from the official marketplace, and
# caveman (terse output mode, /caveman) from its own marketplace. Claude
# downloads both on its next start; nothing is packaged here.
#
# ~/.claude/settings.json is not linked: herdr's integration and /plugin
# write to it at runtime. Activation merges these keys into it instead,
# leaving every other key alone, so a plugin disabled through /plugin comes
# back on the next switch.
{ ... }:
{
  den.aspects.home-claude-plugins.provides.to-users.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      fragment = pkgs.writeText "claude-plugins.json" (
        builtins.toJSON {
          enabledPlugins = {
            "superpowers@claude-plugins-official" = true;
            "caveman@caveman" = true;
          };
          extraKnownMarketplaces.caveman.source = {
            source = "github";
            repo = "JuliusBrussee/caveman";
          };
        }
      );
    in
    {
      home.activation.claudePlugins = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        f="${config.home.homeDirectory}/.claude/settings.json"
        old='{}'
        [ -s "$f" ] && old=$(cat "$f")
        new=$(printf '%s' "$old" | ${lib.getExe pkgs.jq} --slurpfile add ${fragment} '. * $add[0]')
        if [ "$new" != "$(printf '%s' "$old" | ${lib.getExe pkgs.jq} .)" ]; then
          tmp=$(mktemp)
          printf '%s\n' "$new" > "$tmp"
          run mkdir -p "$(dirname "$f")"
          run install -m 644 "$tmp" "$f"
          rm -f "$tmp"
        fi
      '';
    };
}
