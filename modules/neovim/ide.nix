# `vimzuna`: Neovim as an IDE, i.e. the `vimzuna` zellij session (or a
# re-attach to it) opened on the `vimzuna` layout: nvim in its own tab,
# closed with it. Shells, builds and Claude are panes next to it, reached
# with Ctrl+hjkl (homes/zellij.nix).
{ den, ... }:
{
  den.aspects.neovim = {
    includes = [ den.aspects.home-zellij ];

    provides.to-users.homeManager =
      { pkgs, ... }:
      {
        xdg.configFile."zellij/layouts/vimzuna.kdl".text = ''
          layout {
              default_tab_template {
                  pane size=1 borderless=true {
                      plugin location="zellij:tab-bar"
                  }
                  children
                  pane size=2 borderless=true {
                      plugin location="zellij:status-bar"
                  }
              }
              tab name="nvim" focus=true {
                  pane command="nvim" close_on_exit=true
              }
          }
        '';

        home.packages = [
          (pkgs.writeShellApplication {
            name = "vimzuna";
            runtimeInputs = [ pkgs.zellij ];
            text = ''
              session="vimzuna"
              if zellij list-sessions --short --no-formatting 2>/dev/null \
                  | grep -qx "$session"; then
                exec zellij attach "$session"
              else
                exec zellij --layout vimzuna --session "$session"
              fi
            '';
          })
        ];
      };
  };
}
