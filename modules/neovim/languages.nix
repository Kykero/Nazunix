{ ... }:
{
  vimzuna.languages.vim =
    { pkgs, ... }:
    {
      extraPackages = with pkgs; [
        nixfmt # nix formatter
        shfmt # bash formatter
      ];

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
