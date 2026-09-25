# graphify: turns a folder (code, docs, PDFs) into a knowledge graph that
# Claude Code queries through the /graphify skill. The skill files are
# what `graphify install --platform claude` writes, generated at build time
# in a scratch HOME so they always match the packaged version; the global
# CLAUDE.md gets the same pointer the installer appends.
{ ... }:
{
  den.aspects.home-graphify.provides.to-users.homeManager =
    { pkgs, ... }:
    let
      skill = pkgs.runCommand "graphify-skill" { nativeBuildInputs = [ pkgs.graphify ]; } ''
        export HOME=$TMPDIR
        graphify install --platform claude
        cp -r $HOME/.claude/skills/graphify $out
      '';
    in
    {
      home.packages = [ pkgs.graphify ];

      home.file.".claude/skills/graphify".source = skill;
      home.file.".claude/CLAUDE.md".text = ''
        # graphify
        - **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
        When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.
      '';
    };
}
