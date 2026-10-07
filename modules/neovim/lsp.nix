{ ... }:
{
  vimzuna.lsp.vim = {
    autocomplete.blink-cmp.enable = true;

    lsp = {
      enable = true;
      formatOnSave = true;
      trouble.enable = true; # liste de diagnostics navigable
      lspsaga.enable = false;
      lightbulb.enable = true; # indicateur de code action dispo

      mappings.format = null;
    };

    diagnostics = {
      enable = true;
      config = {
        virtual_text = true;
        underline = true;
        update_in_insert = false;
      };
    };
    keymaps = [
      {
        key = "<leader>lf";
        mode = [ "n" ];
        action = "function() require('conform').format({ async = true, lsp_fallback = true }) end";
        lua = true;
        desc = "Format buffer";
      }
    ];
  };
}
