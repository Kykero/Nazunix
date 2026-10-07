{ ... }:
{
  vimzuna.television.vim =
    { pkgs, ... }:
    {
      extraPackages = [
        pkgs.television
        pkgs.bat
        # sources of the files (fd) and text (rg) channels
        pkgs.fd
        pkgs.ripgrep
      ];

      extraPlugins.tv-nvim = {
        package = pkgs.vimPlugins.tv-nvim;
        setup = ''
          local h = require("tv").handlers
          require("tv").setup({
            tv_binary = "tv",
            channels = {
              files = {
                keybinding = "<leader>ff",
                handlers = {
                  ["<CR>"]  = h.open_as_files,
                  ["<C-q>"] = h.send_to_quickfix,
                  ["<C-s>"] = h.open_in_split,
                  ["<C-v>"] = h.open_in_vsplit,
                  ["<C-y>"] = h.copy_to_clipboard,
                },
              },
              text = {
                keybinding = "<leader>fg",
                handlers = {
                  ["<CR>"]  = h.open_at_line,
                  ["<C-q>"] = h.send_to_quickfix,
                  ["<C-s>"] = h.open_in_split,
                  ["<C-v>"] = h.open_in_vsplit,
                  ["<C-y>"] = h.copy_to_clipboard,
                },
              },
            },
            global_keybindings = {
              channels = "<leader>fc",
            },
            quickfix = {
              auto_open = true,
            },
          })
        '';
      };
    };
}
