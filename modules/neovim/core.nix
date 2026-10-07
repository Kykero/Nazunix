{ ... }:
{
  vimzuna.core = {

    vim = {
      viAlias = true;
      vimAlias = true;
      globals.mapleader = " ";
      globals.maplocalleader = " ";

      theme = {
        enable = true;
        name = "tokyonight";
        style = "moon";
      };

      opts = {
        number = true;
        relativenumber = true;
        shiftwidth = 2;
        tabstop = 2;
        expandtab = true;
        smartindent = true;
        breakindent = true;
        linebreak = true;
      };

      spellcheck = {
        enable = true;
        languages = [
          "fr"
          "en"
        ];
      };

      statusline.lualine.enable = true;

      binds.whichKey = {
        enable = true;
        setupOpts.delay = 0;
      };

      mini.icons.enable = true;
    };

  };
}
