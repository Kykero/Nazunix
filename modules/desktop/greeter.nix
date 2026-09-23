# Login screen: Noctalia's greetd greeter, packaged and wired by nixpkgs.
# services.displayManager.noctalia-greeter turns on greetd (which creates the
# greeter user, pins VT1 and enables services.displayManager), polkit and
# accounts-daemon. noctalia-greeter-session starts its own wlroots compositor,
# so no cage/niri wrapper is needed. The "Niri" session file registered by
# niri-flake reaches the greeter through XDG_DATA_DIRS (pam_env).
#
# Noctalia's "sync to greeter" runs a root helper through pkexec.
# passwordlessSyncUsers adds nixpkgs' polkit rule for the constrained
# org.noctalia.greeter.sync-appearance action (greeter >= 1.3.1; the older
# apply-appearance action is never authorised), local active sessions only.
{ lib, ... }:
{
  den.aspects.desktop-greeter.nixos =
    { host, ... }:
    {
      services.displayManager.noctalia-greeter = {
        enable = true;
        settings.keyboard.layout = "fr";
        passwordlessSyncUsers = lib.mapAttrsToList (_: user: user.userName) host.users;
      };
    };
}
