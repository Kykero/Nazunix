# omo-graph: one place to watch every agent session in herdr as a zoetrope
# graph (docs/omo.md). Run it in any pane: it lists the live claude and
# codex sessions, threads and omo's own Claude children included, most
# recent first; a number opens that graph, `q` in the graph comes back to
# the list, `a` follows the newest session and switches when a new one
# starts.
#
# omo's children need the extra lookup: omo starts Claude Code with
# `--setting-sources=` (no user settings), so herdr's hooks never fire in
# them and herdr never learns their session id. The id is on the child's
# command line (--session-id, or --resume; a fork takes the newest
# transcript of its folder), and the transcript is an ordinary Claude Code
# session.
# `zoe` comes from zoetrope.nix, on PATH.
{ inputs, ... }:
{
  den.aspects.home-omo-graph.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.writeShellApplication {
          name = "omo-graph";
          runtimeInputs = [
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr
            pkgs.coreutils
            pkgs.findutils
            pkgs.gawk
            pkgs.gnused
            pkgs.jq
            pkgs.ncurses
          ];
          text = builtins.readFile ./omo-graph.sh;
        })
      ];
    };
}
