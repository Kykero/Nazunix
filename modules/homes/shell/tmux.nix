# tmux, the terminal multiplexer Neovim lives in (`vimzuna`, neovim/ide.nix).
# Stock prefix (C-b) and stock binds; on top, Ctrl+hjkl (move) and Alt+hjkl
# (resize) are the tmux side of smart-splits.nvim
# (modules/neovim/navigation.nix): when the pane runs Neovim (@pane-is-vim,
# set by smart-splits) the key is passed through, so the same keys cross
# nvim splits and tmux panes alike.
# Sessions, pane contents included, are saved by resurrect every 15
# minutes and restored by continuum when the server starts. The status bar
# lives in tmux-status.nix. tmux never starts with fish: it is opened on
# demand.
{ den, lib, ... }:
{
  den.aspects.home-tmux.includes = [ den.aspects.home-tmux-status ];

  den.aspects.home-tmux.provides.to-users.homeManager =
    { pkgs, ... }:
    let
      directions = {
        h = "L";
        j = "D";
        k = "U";
        l = "R";
      };
      bind =
        key: dir:
        ''
          bind-key -n C-${key} if -F "#{@pane-is-vim}" 'send-keys C-${key}' 'select-pane -${dir}'
          bind-key -n M-${key} if -F "#{@pane-is-vim}" 'send-keys M-${key}' 'resize-pane -${dir} 3'
          bind-key -T copy-mode-vi C-${key} select-pane -${dir}
        '';
    in
    {
      programs.tmux = {
        enable = true;
        mouse = true;
        escapeTime = 0;
        focusEvents = true;
        terminal = "tmux-256color";
        plugins = with pkgs.tmuxPlugins; [
          {
            plugin = resurrect;
            extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
          }
          {
            plugin = continuum;
            extraConfig = "set -g @continuum-restore 'on'";
          }
        ];
        extraConfig = lib.concatStrings (lib.mapAttrsToList bind directions);
      };
    };
}
