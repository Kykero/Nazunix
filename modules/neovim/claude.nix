# claudecode.nvim — bridges Neovim with the Claude Code CLI over the
# MCP WebSocket protocol. The `claude` CLI itself is NOT provided here:
# it comes with the full profile (modules/homes/claude-code.nix).
#
# Claude runs in a zellij pane via the "external" terminal provider:
# the MCP server lives in Neovim, the CLI connects back through
# ~/.claude/ide lock files. Outside zellij, the native terminal
# provider is used as a fallback.
{ ... }:
{
  vimzuna.claude.vim =
    { pkgs, ... }:
    {
      extraPlugins.claudecode-nvim = {
        package = pkgs.vimPlugins.claudecode-nvim;
        setup = ''
          local terminal
          if vim.env.ZELLIJ then
            terminal = {
              provider = "external",
              provider_opts = {
                -- new pane on the right, closed when claude exits
                external_terminal_cmd = "zellij run -c -d right -- %s",
              },
            }
          else
            terminal = { provider = "native" }
          end

          require("claudecode").setup({
            terminal = terminal,
          })
        '';
      };

      keymaps = [
        {
          key = "<leader>ac";
          mode = [ "n" ];
          action = "<cmd>ClaudeCode<cr>";
          desc = "Claude: toggle";
        }
        {
          key = "<leader>as";
          mode = [ "v" ];
          action = "<cmd>ClaudeCodeSend<cr>";
          desc = "Claude: send selection";
        }
        {
          key = "<leader>ab";
          mode = [ "n" ];
          action = "<cmd>ClaudeCodeAdd %<cr>";
          desc = "Claude: add current buffer";
        }
        {
          key = "<leader>aa";
          mode = [ "n" ];
          action = "<cmd>ClaudeCodeDiffAccept<cr>";
          desc = "Claude: accept diff";
        }
        {
          key = "<leader>ad";
          mode = [ "n" ];
          action = "<cmd>ClaudeCodeDiffDeny<cr>";
          desc = "Claude: deny diff";
        }
      ];
    };
}
