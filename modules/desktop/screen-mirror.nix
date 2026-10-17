# Screen mirroring for projectors. niri extends the desktop onto a second
# output and cannot mirror one, so Mod+P runs wl-mirror: it shows the
# focused output, fullscreen, on the first other output, and a second
# Mod+P closes it. With a single output it does nothing.
{ ... }:
{
  den.aspects.desktop-screen-mirror.provides.to-users.homeManager =
    { pkgs, ... }:
    let
      niri-mirror = pkgs.writeShellApplication {
        name = "niri-mirror";
        runtimeInputs = [
          pkgs.wl-mirror
          pkgs.jq
          pkgs.procps
        ];
        text = ''
          if pkill -x wl-mirror; then
            exit 0
          fi
          source=$(niri msg --json focused-output | jq -r .name)
          target=$(niri msg --json outputs | jq -r --arg s "$source" 'to_entries[] | select(.key != $s and .value.current_mode != null) | .key' | head -n 1)
          if [ -z "$target" ]; then
            exit 0
          fi
          exec wl-mirror --fullscreen-output "$target" "$source"
        '';
      };
    in
    {
      home.packages = [ niri-mirror ];

      programs.niri.settings.binds."Mod+P" = {
        hotkey-overlay.title = "Mirror this screen to the other one";
        action.spawn = "niri-mirror";
      };
    };
}
