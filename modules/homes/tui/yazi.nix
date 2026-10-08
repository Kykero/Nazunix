# Yazi, the terminal file manager, in every shell; Neovim opens it too
# (<leader>n, modules/neovim/yazi.nix). `y` is the fish wrapper that cds
# into the last directory on quit.
{ ... }:
{
  den.aspects.home-yazi.provides.to-users.homeManager.programs.yazi = {
    enable = true;
    shellWrapperName = "y";
  };
}
