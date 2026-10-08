# rtk ("Rust Token Killer"): a PreToolUse hook rewrites Claude Code's Bash
# commands (git, ls, find, test runners...) through rtk, which compacts
# their output before it reaches the model; `rtk gain` shows the savings.
#
# This does what `rtk init -g` does, without letting it edit files at
# runtime: RTK.md is generated at build time by running rtk init in a
# scratch HOME, the global CLAUDE.md imports it, and activation adds the
# hook to ~/.claude/settings.json (see claude-plugins.nix for why that file
# is merged, not linked), replacing any earlier rtk entry.
{ ... }:
{
  den.aspects.home-rtk.provides.to-users.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      init = pkgs.runCommand "rtk-init" { nativeBuildInputs = [ pkgs.rtk ]; } ''
        export HOME=$TMPDIR
        mkdir -p $HOME/.claude
        rtk init -g --auto-patch </dev/null
        install -Dm644 $HOME/.claude/RTK.md $out/RTK.md
      '';
      hook = pkgs.writeText "rtk-hook.json" (
        builtins.toJSON {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "rtk hook claude";
            }
          ];
        }
      );
    in
    {
      home.packages = [ pkgs.rtk ];

      home.file.".claude/RTK.md".source = "${init}/RTK.md";
      home.file.".claude/CLAUDE.md".text = ''
        @RTK.md
      '';

      home.activation.claudeRtkHook = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        f="${config.home.homeDirectory}/.claude/settings.json"
        old='{}'
        [ -s "$f" ] && old=$(cat "$f")
        new=$(printf '%s' "$old" | ${lib.getExe pkgs.jq} --slurpfile h ${hook} '
          .hooks.PreToolUse = [
            (.hooks.PreToolUse // [])[]
            | select(any(.hooks[]?; .command | test("rtk hook claude")) | not)
          ] + $h')
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
