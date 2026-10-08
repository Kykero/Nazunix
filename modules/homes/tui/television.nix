# Television (`tv`), the fuzzy finder behind Neovim's <leader>f binds
# (modules/neovim/television.nix), in every shell. Its fish integration
# binds Ctrl+T (smart autocomplete) and Ctrl+R (history).
{ ... }:
{
  den.aspects.home-television.provides.to-users.homeManager.programs.television = {
    enable = true;
  };
}
