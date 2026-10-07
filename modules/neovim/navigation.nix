# smart-splits.nvim — seamless navigation between Neovim splits and
# zellij panes.
#
# The zellij side of the contract is modules/homes/zellij.nix:
# vim-zellij-navigator plugin bound to Ctrl+hjkl / Alt+hjkl.
{ ... }:
{
  vimzuna.navigation.vim =
    { pkgs, ... }:
    {
      extraPlugins.smart-splits-nvim = {
        package = pkgs.vimPlugins.smart-splits-nvim;
        setup = ''
          require("smart-splits").setup({
            at_edge = "stop",
          })
        '';
      };

      keymaps = [
        # --- Move between splits/panes ---
        {
          key = "<C-h>";
          mode = [ "n" "t" ];
          action = "function() require('smart-splits').move_cursor_left() end";
          lua = true;
          desc = "Move to left split/pane";
        }
        {
          key = "<C-j>";
          mode = [ "n" "t" ];
          action = "function() require('smart-splits').move_cursor_down() end";
          lua = true;
          desc = "Move to lower split/pane";
        }
        {
          key = "<C-k>";
          mode = [ "n" "t" ];
          action = "function() require('smart-splits').move_cursor_up() end";
          lua = true;
          desc = "Move to upper split/pane";
        }
        {
          key = "<C-l>";
          mode = [ "n" "t" ];
          action = "function() require('smart-splits').move_cursor_right() end";
          lua = true;
          desc = "Move to right split/pane";
        }

        # --- Resize splits/panes ---
        {
          key = "<A-h>";
          mode = [ "n" "t" ];
          action = "function() require('smart-splits').resize_left() end";
          lua = true;
          desc = "Resize split left";
        }
        {
          key = "<A-j>";
          mode = [ "n" "t" ];
          action = "function() require('smart-splits').resize_down() end";
          lua = true;
          desc = "Resize split down";
        }
        {
          key = "<A-k>";
          mode = [ "n" "t" ];
          action = "function() require('smart-splits').resize_up() end";
          lua = true;
          desc = "Resize split up";
        }
        {
          key = "<A-l>";
          mode = [ "n" "t" ];
          action = "function() require('smart-splits').resize_right() end";
          lua = true;
          desc = "Resize split right";
        }
      ];
    };
}
