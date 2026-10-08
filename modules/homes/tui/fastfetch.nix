# fastfetch with an explicit module list, tuned for NixOS.
# The default Packages module is what makes it slow here: for each profile it
# spawns `nix-store --query --requisites` (~600 ms after every rebuild, since
# the cache is keyed on the profile's store path) and, once cached, still two
# `nix-store --query --hash` calls (~85 ms) on every run. Dropping it brings a
# run down to ~35 ms. Also left out: DE and WMTheme (nothing to report under
# niri) and LocalIp (keeps addresses out of screenshots).
{ ... }:
{
  den.aspects.home-fastfetch.homeManager = {
    programs.fastfetch = {
      enable = true;
      settings = {
        modules = [
          "title"
          "separator"
          "os"
          "host"
          "kernel"
          "uptime"
          "shell"
          "display"
          "wm"
          "theme"
          "icons"
          "font"
          "cursor"
          "terminal"
          "terminalfont"
          "cpu"
          "gpu"
          "memory"
          "swap"
          "disk"
          "battery"
          "poweradapter"
          "locale"
          "break"
          "colors"
        ];
      };
    };
  };
}
