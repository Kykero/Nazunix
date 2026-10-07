# `vimzuna`: Neovim as an IDE, i.e. the `vimzuna` tmux session (or a
# re-attach to it): nvim in its own `nvim` window, closed with it. Shells,
# builds and Claude are panes next to it, reached with Ctrl+hjkl
# (homes/tmux.nix).
{ den, ... }:
{
  den.aspects.neovim = {
    includes = [ den.aspects.home-tmux ];

    provides.to-users.homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (pkgs.writeShellApplication {
            name = "vimzuna";
            runtimeInputs = [ pkgs.tmux ];
            text = ''
              exec tmux new-session -A -s vimzuna -n nvim nvim
            '';
          })
        ];
      };
  };
}
