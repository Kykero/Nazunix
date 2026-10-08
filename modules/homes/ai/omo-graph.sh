# omo-graph: pick any live agent session in herdr and watch it in zoe.
# Sourced by omo-graph.nix (writeShellApplication adds the shebang, set
# -euo pipefail and PATH). Sessions come from two places: herdr's own
# record for each claude/codex pane (`agent_session`), and the Claude Code
# children omo starts with `--setting-sources=`, which herdr never hears
# about (docs/omo.md).

claude_dir="$HOME/.claude/projects"
codex_dir="${CODEX_HOME:-$HOME/.codex}/sessions"

usage() {
  cat <<'EOF'
usage: omo-graph            pick a session from the list, q in the graph returns
       omo-graph -a         follow the newest session, switch when a new one starts
       omo-graph -l         print the list and exit
EOF
}

# transcript path for an agent kind and a session id, empty if none yet
transcript() {
  case "$1" in
    claude)
      for f in "$claude_dir"/*/"$2".jsonl; do
        [ -e "$f" ] && { printf '%s\n' "$f"; return; }
      done
      ;;
    codex)
      [ -d "$codex_dir" ] && find "$codex_dir" -name "*$2.jsonl" -print -quit
      ;;
  esac
}

# one line per session, most recently active first:
#   mtime <TAB> kind <TAB> id <TAB> label <TAB> transcript
sessions() {
  {
    herdr pane list 2>/dev/null | jq -r '
      .result.panes[]?
      | select(.agent_session.kind? == "id")
      | select(.agent_session.agent == "claude" or .agent_session.agent == "codex")
      | [.agent_session.agent, .agent_session.value,
         ((.display_agent // .terminal_title_stripped // .agent) + "  (" + .pane_id + ")")]
      | @tsv'

    labels=$(herdr pane list 2>/dev/null | jq -r '
      .result.panes[]? | [.pane_id, (.display_agent // .terminal_title_stripped // "")] | @tsv')
    # only processes with a bare --setting-sources= argument: one grep over
    # every cmdline instead of a read per process
    while IFS= read -r f; do
      d=${f%/cmdline}
      cmd=$(tr '\0' ' ' 2>/dev/null < "$f") || continue
      read -ra args <<< "$cmd"
      case "${args[0]:-}" in
        claude | */omo-claude | omo-claude) ;;
        *) continue ;;
      esac
      sid=""
      fork=false
      model="claude"
      prev=""
      for a in "${args[@]}"; do
        case "$a" in
          --session-id=*) sid=${a#--session-id=} ;;
          --resume=*) sid=${a#--resume=} ;;
          --fork-session) fork=true ;;
        esac
        [ "$prev" = "--model" ] && model=$a
        [ "$prev" = "--resume" ] && sid=$a
        prev=$a
      done
      # a fork writes a new session under an id it picks itself: take the
      # newest transcript of the process's project folder
      if $fork || [ -z "$sid" ]; then
        cwd=$(readlink "$d/cwd" 2>/dev/null) || continue
        proj="$claude_dir/$(printf '%s' "$cwd" | sed 's/[^A-Za-z0-9]/-/g')"
        newest=$(find "$proj" -maxdepth 1 -name '*.jsonl' -printf '%T@ %p\n' 2>/dev/null \
          | sort -nr | head -n1 | cut -d' ' -f2-) || true
        [ -n "$newest" ] || continue
        sid=$(basename "$newest" .jsonl)
      fi
      pane=$(tr '\0' '\n' 2>/dev/null < "$d/environ" | sed -n 's/^HERDR_PANE_ID=//p')
      where=$(printf '%s\n' "$labels" | awk -F'\t' -v p="$pane" '$1 == p { print $2 }')
      printf 'claude\t%s\tomo %s · %s  (%s)\n' "$sid" "$model" "${where:-?}" "${pane:-?}"
    done < <(grep -lsxzF -- '--setting-sources=' /proc/[0-9]*/cmdline || true)
  } | while IFS=$'\t' read -r kind id label; do
    f=$(transcript "$kind" "$id")
    [ -n "$f" ] || continue
    printf '%s\t%s\t%s\t%s\t%s\n' "$(stat -c %Y "$f")" "$kind" "$id" "$label" "$f"
  done | sort -t$'\t' -k1,1nr | awk -F'\t' '!seen[$3]++'
}

age() {
  local s=$(( $(date +%s) - $1 ))
  if [ "$s" -lt 60 ]; then printf '%ss' "$s"
  elif [ "$s" -lt 3600 ]; then printf '%sm' $(( s / 60 ))
  else printf '%sh' $(( s / 3600 )); fi
}

show_list() {
  local n=0
  while IFS=$'\t' read -r t kind _ label _; do
    [ -n "$t" ] || continue
    n=$(( n + 1 ))
    printf '%3d  %-6s %5s  %s\n' "$n" "$kind" "$(age "$t")" "$label"
  done <<< "$1"
  [ "$n" -gt 0 ] || echo "  no live claude or codex session in herdr yet"
}

# zoe restores the terminal only when it exits on its own; one killed by a
# signal leaves raw mode, the alternate screen and mouse capture behind
tty_saved=$(stty -g 2>/dev/null || true)
restore_tty() {
  [ -n "$tty_saved" ] && stty "$tty_saved" 2>/dev/null
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1049l'
}

# follow the newest session; when one appears that was not there before,
# switch to it. Returns when zoe is quit (q).
auto_follow() {
  local seen rows cur pid new
  rows=$(sessions)
  seen=$(printf '%s\n' "$rows" | cut -f3)
  cur=$(printf '%s\n' "$rows" | head -n1)
  while :; do
    if [ -z "$cur" ]; then
      clear
      echo "omo-graph: waiting for a claude or codex session... (Ctrl-C to stop)"
      sleep 2
      rows=$(sessions)
      cur=$(printf '%s\n' "$rows" | head -n1)
      seen=$(printf '%s\n' "$rows" | cut -f3)
      continue
    fi
    zoe "$(printf '%s\n' "$cur" | cut -f5)" --follow &
    pid=$!
    trap 'kill "$pid" 2>/dev/null; restore_tty' EXIT
    while kill -0 "$pid" 2>/dev/null; do
      sleep 2
      rows=$(sessions)
      new=$(printf '%s\n' "$rows" | awk -F'\t' -v s="$seen" '
        BEGIN { n = split(s, a, "\n"); for (i = 1; i <= n; i++) old[a[i]] = 1 }
        !($3 in old) { print; exit }')
      if [ -n "$new" ]; then
        seen=$(printf '%s\n' "$rows" | cut -f3)
        cur=$new
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
        restore_tty
        continue 2
      fi
    done
    wait "$pid" 2>/dev/null || true
    trap - EXIT
    return
  done
}

mode=pick
while getopts "alh" o; do
  case "$o" in
    a) mode=auto ;;
    l) mode=list ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

case "$mode" in
  list) show_list "$(sessions)"; exit 0 ;;
  auto) auto_follow; exit 0 ;;
esac

while :; do
  rows=$(sessions)
  clear
  echo "omo-graph: agent sessions in herdr, most recent first"
  echo
  show_list "$rows"
  echo
  printf 'number = open its graph (q in the graph comes back here), a = auto-follow, q = quit > '
  choice=""
  # refresh every 3 s until a key is pressed; the list then holds still
  # until Enter, so the number typed is the line on screen
  read -r -s -n1 -t 3 choice || continue
  if [ -n "$choice" ]; then
    printf '%s' "$choice"
    read -r rest || true
    choice=$choice$rest
  fi
  case "$choice" in
    q) exit 0 ;;
    a) auto_follow ;;
    '' ) ;;
    *[!0-9]*) ;;
    *)
      f=$(printf '%s\n' "$rows" | sed -n "${choice}p" | cut -f5)
      [ -n "$f" ] && { zoe "$f" --follow || true; }
      ;;
  esac
done
