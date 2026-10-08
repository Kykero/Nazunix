{ ... }:
{
  vimzuna.languages.vim =
    { pkgs, ... }:
    {
      extraPackages = with pkgs; [
        nixfmt # nix formatter
        shfmt # bash formatter
        tree-sitter # silences nvim-treesitter's "tree-sitter-cli not found"
      ];

      # dap-ui opens/closes with each debug session
      debugger.nvim-dap.ui.enable = true;

      # basedpyright defaults to "recommended": warns on missing stubs,
      # partially unknown types, unused call results... "standard" keeps
      # pyright's usual checks only.
      lsp.servers.basedpyright.settings.basedpyright.analysis.typeCheckingMode = "standard";

      languages = {
        enableTreesitter = true;
        enableExtraDiagnostics = true;
        enableFormat = true;

        nix = {
          enable = true;
          format = {
            enable = true;
            type = [ "nixfmt" ];
          };
          lsp = {
            enable = true;
            servers = [ "nixd" ];
          };
        };

        markdown = {
          enable = true;
          format.enable = true;
          lsp.enable = true;
        };

        bash = {
          enable = true;
          lsp.enable = true;
        };

        python = {
          enable = true;
          format.enable = true;
          lsp.enable = true;
          # mypy (nvim-lint) duplicates basedpyright, and runs with its own
          # python: every numpy/pandas import is reported as missing.
          extraDiagnostics.enable = false;
          # debugpy, launched with the `python` on PATH (direnv's, if any)
          dap.enable = true;
        };

        json = {
          enable = true;
          lsp.enable = true;
        };

        java = {
          enable = true;
          lsp.enable = true;
        };
      };
    };
}
