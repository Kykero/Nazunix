# zellij, the terminal multiplexer Neovim lives in (`vimzuna`, neovim/ide.nix).
# vim-zellij-navigator is bound to Ctrl+hjkl (move) and Alt+hjkl (resize),
# the zellij side of smart-splits.nvim (modules/neovim/navigation.nix): the
# same keys cross nvim splits and zellij panes alike.
# Sessions are serialized, so a session survives a reboot and is revived
# on attach. zellij never starts with fish: it is opened on demand.
{ lib, ... }:
{
  den.aspects.home-zellij.provides.to-users.homeManager =
    { pkgs, ... }:
    let
      navigator = pkgs.fetchurl {
        url = "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.3.0/vim-zellij-navigator.wasm";
        hash = "sha256-d+Wi9i98GmmMryV0ST1ddVh+D9h3z7o0xIyvcxwkxY0=";
      };

      bind = mod: key: name: payload: ''
        bind "${mod} ${key}" {
            MessagePlugin "file:${navigator}" {
                name "${name}";
                payload "${payload}";
                ${if name == "move_focus" then "move_mod" else "resize_mod"} "${lib.toLower mod}";
            };
        }
      '';
      directions = {
        h = "left";
        j = "down";
        k = "up";
        l = "right";
      };
      binds = lib.concatStrings (
        lib.mapAttrsToList (
          key: dir: bind "Ctrl" key "move_focus" dir + bind "Alt" key "resize" dir
        ) directions
      );
    in
    {
      programs.zellij = {
        enable = true;
        enableFishIntegration = false;
        settings.session_serialization = true;
        extraConfig = ''
          keybinds {
              shared_except "locked" {
                  ${binds}
              }
          }
        '';
      };
    };
}
