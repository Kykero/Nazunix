# Text files opened from Nautilus (or xdg-open) go to Neovim in a Ghostty
# window. nvim.desktop is Terminal=true, and GLib picks the terminal from a
# fixed list that Ghostty is not on, so this entry runs it explicitly. With
# arguments, Ghostty starts its own process instead of joining the running
# instance. GIO falls back to a type's parents, so text/plain covers the
# source and config types that subclass it.
{ ... }:
{
  den.aspects.desktop-text-editor.provides.to-users.homeManager =
    let
      types = [
        "text/plain"
        "text/markdown"
        "text/x-log"
        "application/json"
        "application/toml"
        "application/x-yaml"
        "application/x-shellscript"
      ];
    in
    {
      xdg.desktopEntries.nvim-ghostty = {
        name = "Neovim";
        genericName = "Text Editor";
        exec = "ghostty -e nvim %F";
        icon = "nvim";
        terminal = false;
        categories = [
          "Utility"
          "TextEditor"
        ];
        mimeType = types;
      };

      xdg.mimeApps.defaultApplications = builtins.listToAttrs (
        map (type: {
          name = type;
          value = "nvim-ghostty.desktop";
        }) types
      );
    };
}
