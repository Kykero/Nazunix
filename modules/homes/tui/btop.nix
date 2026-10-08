{ ... }:
{
  den.aspects.home-btop.homeManager = {
    programs.btop = {
      enable = true;
      settings = {
        vim_keys = true;
        theme_background = false; # blend into the terminal's own background
      };
    };
  };
}
