# tmux status bar: one discreet line at the top, so the bottom of the
# screen stays to the program in the pane (Claude Code's prompt and footer).
# No background, terminal palette colors only, so it follows the ghostty
# theme: session on the left, windows in the middle, the active one
# highlighted, a prefix marker and the clock on the right.
{ ... }:
{
  den.aspects.home-tmux-status.provides.to-users.homeManager.programs.tmux.extraConfig = ''
    set -g status-position top
    set -g status-justify centre
    set -g status-style "bg=default,fg=brightblack"
    set -g status-left "#[fg=blue,bold] #S "
    set -g status-left-length 30
    set -g status-right "#{?client_prefix,#[fg=yellow bold]PREFIX ,}#[fg=brightblack]%H:%M "
    set -g window-status-format " #I:#W "
    set -g window-status-current-format "#[fg=magenta,bold] #I:#W "
    set -g window-status-separator ""
    set -g pane-border-style "fg=brightblack"
    set -g pane-active-border-style "fg=blue"
    set -g message-style "bg=default,fg=yellow"
  '';
}
