# niri key binds: the v26.04 default-config.kdl binds section, transposed to
# an AZERTY (xkb "fr") keyboard.
#
# niri matches a bind against the *unshifted* keysym of the pressed key, so a
# bind has to name what the key produces without Shift on the fr layout, never
# the character printed on a US keyboard. Everything that is a letter or a
# named key (arrows, Home, Print, XF86*) is unchanged. What moves:
#
#   QWERTY default        AZERTY here            why
#   Mod+1 .. Mod+9        ampersand eacute quotedbl apostrophe parenleft
#                         minus egrave underscore ccedilla
#                                                unshifted number row on fr
#   Mod+Shift+Slash       Mod+Shift+colon        "/" is Shift+":" on fr
#   Mod+Period            Mod+semicolon          the key printed ";" / "."
#   Mod+Minus / Mod+Equal Mod+parenright / Mod+Equal
#                                                same physical keys ()°  =+);
#                                                "minus" is the "6" key on fr
#   Mod+BracketLeft/Right Mod+dead_circumflex / Mod+dollar
#                                                same physical keys ^¨  $£;
#                                                [ ] need AltGr on fr
#
# Programs: ghostty (terminal.nix); launcher and lock go through Noctalia's
# IPC instead of fuzzel/swaylock.
{ ... }:
{
  den.aspects.desktop-niri-binds.provides.to-users.homeManager = {
    programs.niri.settings.binds = {
      # Mod-Shift-/ on QWERTY: shows a list of important hotkeys.
      "Mod+Shift+colon".action.show-hotkey-overlay = [ ];

      # terminal, app launcher, screen locker
      "Ctrl+Alt+T" = {
        action.spawn = "ghostty";
        hotkey-overlay.hidden = true; 
      };
      "Mod+Space" = {
        action.spawn-sh = "noctalia msg panel-toggle launcher";
        hotkey-overlay.title = "Run an Application: noctalia";
      };
      # settings is a window in Noctalia v5, not a panel: no panel-toggle
      "Mod+I" = {
        action.spawn-sh = "noctalia msg settings-toggle";
        hotkey-overlay.title = "Settings: noctalia";
      };
      "Super+Alt+L" = {
        action.spawn-sh = "noctalia msg session lock";
        hotkey-overlay.title = "Lock the Screen: noctalia";
      };

      # screen reader toggle
      "Super+Alt+S" = {
        action.spawn-sh = "pkill orca || exec orca";
        allow-when-locked = true;
        hotkey-overlay.hidden = true;
      };

      # volume keys for PipeWire & WirePlumber
      "XF86AudioRaiseVolume" = {
        action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
        allow-when-locked = true;
      };
      "XF86AudioLowerVolume" = {
        action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
        allow-when-locked = true;
      };
      "XF86AudioMute" = {
        action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        allow-when-locked = true;
      };
      "XF86AudioMicMute" = {
        action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        allow-when-locked = true;
      };

      # media keys for any MPRIS player, through playerctl
      "XF86AudioPlay" = {
        action.spawn-sh = "playerctl play-pause";
        allow-when-locked = true;
      };
      "XF86AudioStop" = {
        action.spawn-sh = "playerctl stop";
        allow-when-locked = true;
      };
      "XF86AudioPrev" = {
        action.spawn-sh = "playerctl previous";
        allow-when-locked = true;
      };
      "XF86AudioNext" = {
        action.spawn-sh = "playerctl next";
        allow-when-locked = true;
      };

      # brightness keys for brightnessctl
      "XF86MonBrightnessUp" = {
        action.spawn = [ "brightnessctl" "--class=backlight" "set" "+10%" ];
        allow-when-locked = true;
      };
      "XF86MonBrightnessDown" = {
        action.spawn = [ "brightnessctl" "--class=backlight" "set" "10%-" ];
        allow-when-locked = true;
      };

      # overview: a zoomed-out view of workspaces and windows
      "Mod+O" = {
        action.toggle-overview = [ ];
        repeat = false;
      };

      "Mod+Q" = {
        action.close-window = [ ];
        repeat = false;
      };

      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Down".action.focus-window-down = [ ];
      "Mod+Up".action.focus-window-up = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+H".action.focus-column-left = [ ];
      "Mod+J".action.focus-window-down = [ ];
      "Mod+K".action.focus-window-up = [ ];
      "Mod+L".action.focus-column-right = [ ];

      "Mod+Ctrl+Left".action.move-column-left = [ ];
      "Mod+Ctrl+Down".action.move-window-down = [ ];
      "Mod+Ctrl+Up".action.move-window-up = [ ];
      "Mod+Ctrl+Right".action.move-column-right = [ ];
      "Mod+Ctrl+H".action.move-column-left = [ ];
      "Mod+Ctrl+J".action.move-window-down = [ ];
      "Mod+Ctrl+K".action.move-window-up = [ ];
      "Mod+Ctrl+L".action.move-column-right = [ ];

      "Mod+Home".action.focus-column-first = [ ];
      "Mod+End".action.focus-column-last = [ ];
      "Mod+Ctrl+Home".action.move-column-to-first = [ ];
      "Mod+Ctrl+End".action.move-column-to-last = [ ];

      "Mod+Shift+Left".action.focus-monitor-left = [ ];
      "Mod+Shift+Down".action.focus-monitor-down = [ ];
      "Mod+Shift+Up".action.focus-monitor-up = [ ];
      "Mod+Shift+Right".action.focus-monitor-right = [ ];
      "Mod+Shift+H".action.focus-monitor-left = [ ];
      "Mod+Shift+J".action.focus-monitor-down = [ ];
      "Mod+Shift+K".action.focus-monitor-up = [ ];
      "Mod+Shift+L".action.focus-monitor-right = [ ];

      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
      "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
      "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
      "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
      "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];

      "Mod+Page_Down".action.focus-workspace-down = [ ];
      "Mod+Page_Up".action.focus-workspace-up = [ ];
      "Mod+U".action.focus-workspace-down = [ ];
      # Mod+I opens Noctalia's settings instead (top of the file); Mod+Page_Up remains
      "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
      "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];

      "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
      "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
      "Mod+Shift+U".action.move-workspace-down = [ ];
      "Mod+Shift+I".action.move-workspace-up = [ ];

      # mouse wheel, rate-limited so workspaces don't fly by
      "Mod+WheelScrollDown" = {
        action.focus-workspace-down = [ ];
        cooldown-ms = 150;
      };
      "Mod+WheelScrollUp" = {
        action.focus-workspace-up = [ ];
        cooldown-ms = 150;
      };
      "Mod+Ctrl+WheelScrollDown" = {
        action.move-column-to-workspace-down = [ ];
        cooldown-ms = 150;
      };
      "Mod+Ctrl+WheelScrollUp" = {
        action.move-column-to-workspace-up = [ ];
        cooldown-ms = 150;
      };

      "Mod+WheelScrollRight".action.focus-column-right = [ ];
      "Mod+WheelScrollLeft".action.focus-column-left = [ ];
      "Mod+Ctrl+WheelScrollRight".action.move-column-right = [ ];
      "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [ ];

      # Shift + wheel scrolls horizontally in apps; same here
      "Mod+Shift+WheelScrollDown".action.focus-column-right = [ ];
      "Mod+Shift+WheelScrollUp".action.focus-column-left = [ ];
      "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [ ];
      "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [ ];

      # workspaces by index: the unshifted AZERTY number row
      "Mod+ampersand".action.focus-workspace = 1;
      "Mod+eacute".action.focus-workspace = 2;
      "Mod+quotedbl".action.focus-workspace = 3;
      "Mod+apostrophe".action.focus-workspace = 4;
      "Mod+parenleft".action.focus-workspace = 5;
      "Mod+minus".action.focus-workspace = 6;
      "Mod+egrave".action.focus-workspace = 7;
      "Mod+underscore".action.focus-workspace = 8;
      "Mod+ccedilla".action.focus-workspace = 9;
      "Mod+Ctrl+ampersand".action.move-column-to-workspace = 1;
      "Mod+Ctrl+eacute".action.move-column-to-workspace = 2;
      "Mod+Ctrl+quotedbl".action.move-column-to-workspace = 3;
      "Mod+Ctrl+apostrophe".action.move-column-to-workspace = 4;
      "Mod+Ctrl+parenleft".action.move-column-to-workspace = 5;
      "Mod+Ctrl+minus".action.move-column-to-workspace = 6;
      "Mod+Ctrl+egrave".action.move-column-to-workspace = 7;
      "Mod+Ctrl+underscore".action.move-column-to-workspace = 8;
      "Mod+Ctrl+ccedilla".action.move-column-to-workspace = 9;

      # move the focused window in and out of a column (QWERTY: Mod+[ and Mod+])
      "Mod+dead_circumflex".action.consume-or-expel-window-left = [ ];
      "Mod+dollar".action.consume-or-expel-window-right = [ ];

      # consume one window from the right into the column / expel the bottom one
      "Mod+Comma".action.consume-window-into-column = [ ];
      "Mod+semicolon".action.expel-window-from-column = [ ];

      "Mod+R".action.switch-preset-column-width = [ ];
      "Mod+Shift+R".action.switch-preset-column-width-back = [ ];
      "Mod+Ctrl+Shift+R".action.switch-preset-window-height = [ ];
      "Mod+Ctrl+R".action.reset-window-height = [ ];
      "Mod+F".action.maximize-column = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];

      # maximize-column keeps gaps and borders, this one expands to the edges
      "Mod+M".action.maximize-window-to-edges = [ ];

      # expand the focused column to the space left by other visible columns
      "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];

      "Mod+C".action.center-column = [ ];
      "Mod+Ctrl+C".action.center-visible-columns = [ ];

      # finer width / height adjustments (QWERTY: Mod+- and Mod+=)
      "Mod+parenright".action.set-column-width = "-10%";
      "Mod+Equal".action.set-column-width = "+10%";
      "Mod+Shift+parenright".action.set-window-height = "-10%";
      "Mod+Shift+Equal".action.set-window-height = "+10%";

      # floating <-> tiling
      "Mod+V".action.toggle-window-floating = [ ];
      "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];

      # tabbed column display
      "Mod+W".action.toggle-column-tabbed-display = [ ];

      "Print".action.screenshot = [ ];
      "Ctrl+Print".action.screenshot-screen = [ ];
      "Alt+Print".action.screenshot-window = [ ];

      # escape hatch when an app inhibits the compositor shortcuts
      "Mod+Escape" = {
        action.toggle-keyboard-shortcuts-inhibit = [ ];
        allow-inhibiting = false;
      };

      # quit shows a confirmation dialog; the escape hatch if Noctalia is down
      "Mod+Shift+E".action.quit = [ ];

      # Noctalia's session menu: lock, log out, suspend, reboot, shut down
      "Ctrl+Alt+Delete" = {
        action.spawn-sh = "noctalia msg panel-toggle session";
        hotkey-overlay.title = "Session Menu: noctalia";
      };

      "Mod+Shift+P".action.power-off-monitors = [ ];
    };
  };
}
