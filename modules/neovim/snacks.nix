# Single aspect for snacks.nvim — all modules and setupOpts in one place
# to avoid cross-aspect setupOpts merge issues.
{ ... }:
{
  vimzuna.snacks.vim =
    { pkgs, ... }:
    {
      extraPackages = with pkgs; [
        lazygit
        gh
      ];

      utility.snacks-nvim = {
        enable = true;
        setupOpts = {
          # --- QoL ---
          scroll.enabled = true;
          quickfile.enabled = true;
          bigfile.enabled = true;
          input.enabled = true;

          # --- Notifier ---
          notifier.enabled = true;

          # --- Lazygit ---
          lazygit.enabled = true;

          # --- GitHub ---
          picker.enabled = true;
          gh.enabled = true;

          # --- Dashboard ---
          dashboard = {
            enabled = true;
            preset = {
              header = ''
【=◈︿◈=】
Is anyone there ?
Oh -
Hi ! 
              '';
              keys = [
                { icon = " "; key = "f"; desc = "Find File"; action = ":lua Snacks.dashboard.pick('files')"; }
                { icon = " "; key = "g"; desc = "Find Text"; action = ":lua Snacks.dashboard.pick('live_grep')"; }
                { icon = " "; key = "r"; desc = "Recent Files"; action = ":lua Snacks.dashboard.pick('oldfiles')"; }
                { icon = " "; key = "n"; desc = "New File"; action = ":ene | startinsert"; }
                { icon = " "; key = "q"; desc = "Quit"; action = ":qa"; }
              ];
            };
            sections = [
              { section = "header"; }
              { section = "keys"; gap = 1; padding = 1; }
              { icon = " "; title = "Recent Files"; section = "recent_files"; indent = 2; padding = 1; }
              { icon = " "; title = "Projects"; section = "projects"; indent = 2; padding = 1; }
            ];
          };
        };
      };

      keymaps = [
        # --- Lazygit ---
        {
          key = "<leader>gg";
          mode = [ "n" ];
          action = "function() Snacks.lazygit() end";
          lua = true;
          desc = "Lazygit";
        }

        # --- GitHub ---
        {
          key = "<leader>gi";
          mode = [ "n" ];
          action = "function() Snacks.picker.gh_issue() end";
          lua = true;
          desc = "GitHub Issues (open)";
        }
        {
          key = "<leader>gI";
          mode = [ "n" ];
          action = "function() Snacks.picker.gh_issue({ state = 'all' }) end";
          lua = true;
          desc = "GitHub Issues (all)";
        }
        {
          key = "<leader>gp";
          mode = [ "n" ];
          action = "function() Snacks.picker.gh_pr() end";
          lua = true;
          desc = "GitHub PRs (open)";
        }
        {
          key = "<leader>gP";
          mode = [ "n" ];
          action = "function() Snacks.picker.gh_pr({ state = 'all' }) end";
          lua = true;
          desc = "GitHub PRs (all)";
        }

        # --- Notifier ---
        {
          key = "<leader>uh";
          mode = [ "n" ];
          action = "function() Snacks.notifier.show_history() end";
          lua = true;
          desc = "Notification history";
        }
        {
          key = "<leader>ud";
          mode = [ "n" ];
          action = "function() Snacks.notifier.hide() end";
          lua = true;
          desc = "Dismiss notifications";
        }
      ];
    };
}
