# omo-graph: zoetrope for the Claude Code sessions OmO runs. omo starts
# its Claude Code children with `--setting-sources=` (no user settings), so
# herdr's hooks never fire in them: herdr sees a `claude` process in the
# omo pane but never learns its session id, and prefix+shift+z has nothing
# to open. The id is on the child's command line, though, and the session
# file is an ordinary Claude Code transcript that zoe reads.
#
#   omo-graph            follow the oldest live child (omo's main Claude)
#   omo-graph -l         list the live children, oldest first
#   omo-graph -p PANE    only children of the omo in that herdr pane
#   omo-graph -n N       follow the Nth child of the list instead
#
# Run it in a split beside the omo pane (docs/omo.md).
{ ... }:
{
  den.aspects.home-omo-graph.provides.to-users.homeManager =
    { config, pkgs, ... }:
    {
      home.packages = [
        (pkgs.writeShellApplication {
          name = "omo-graph";
          runtimeInputs = [
            pkgs.coreutils
            pkgs.gawk
            pkgs.gnugrep
          ];
          text = ''
            list=false
            pane=""
            nth=1
            while getopts "lp:n:" o; do
              case "$o" in
                l) list=true ;;
                p) pane=$OPTARG ;;
                n) nth=$OPTARG ;;
                *) echo "usage: omo-graph [-l] [-p PANE] [-n N]" >&2; exit 2 ;;
              esac
            done

            # one line per omo-started claude: start tick, session id, model
            children() {
              for d in /proc/[0-9]*; do
                cmd=$(tr '\0' ' ' 2>/dev/null < "$d/cmdline") || continue
                case "$cmd" in
                  "claude "*"--setting-sources= "*) ;;
                  *) continue ;;
                esac
                sid=""
                model="?"
                prev=""
                read -ra args <<< "$cmd"
                for a in "''${args[@]}"; do
                  case "$a" in
                    --session-id=*) sid=''${a#--session-id=} ;;
                  esac
                  [ "$prev" = "--model" ] && model=$a
                  prev=$a
                done
                [ -n "$sid" ] || continue
                if [ -n "$pane" ]; then
                  grep -qxzF "HERDR_PANE_ID=$pane" "$d/environ" 2>/dev/null || continue
                fi
                stat=$(cat "$d/stat" 2>/dev/null) || continue
                read -ra fields <<< "''${stat##*) }"
                printf '%s %s %s\n' "''${fields[19]}" "$sid" "$model"
              done | sort -n
            }

            rows=$(children)
            if [ -z "$rows" ]; then
              echo "omo-graph: no live Claude Code session started by omo" >&2
              exit 1
            fi
            if $list; then
              printf '%s\n' "$rows" | awk '{ printf "%d  %s  %s\n", NR, $2, $3 }'
              exit 0
            fi

            sid=$(printf '%s\n' "$rows" | awk -v n="$nth" 'NR == n { print $2 }')
            if [ -z "$sid" ]; then
              echo "omo-graph: no child number $nth (see omo-graph -l)" >&2
              exit 1
            fi
            for f in "${config.home.homeDirectory}"/.claude/projects/*/"$sid".jsonl; do
              [ -e "$f" ] && exec zoe "$f" --follow
            done
            echo "omo-graph: session $sid has no transcript yet" >&2
            exit 1
          '';
        })
      ];
    };
}
