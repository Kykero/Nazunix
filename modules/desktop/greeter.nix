# Login screen: Noctalia's greetd greeter, packaged and wired by nixpkgs.
# services.displayManager.noctalia-greeter turns on greetd (which creates the
# greeter user, pins VT1 and enables services.displayManager), polkit and
# accounts-daemon. noctalia-greeter-session starts its own wlroots compositor,
# so no cage/niri wrapper is needed. The "Niri" session file registered by
# niri-flake reaches the greeter through XDG_DATA_DIRS (pam_env).
{ ... }:
{
  den.aspects.desktop-greeter.nixos = {
    services.displayManager.noctalia-greeter = {
      enable = true;
      settings.keyboard.layout = "fr";
    };
  };
}
