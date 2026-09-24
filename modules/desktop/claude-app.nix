# Claude desktop app (chat and Claude Code sessions) from llm-agents
# (numtide): Anthropic's prebuilt Linux release, repackaged, nothing to
# compile. Its unfree licence is llm-agents' own, which evaluates without
# allowUnfree. The desktop entry registers x-scheme-handler/claude for the
# OAuth sign-in with the subscription.
#
# Electron only picks the libsecret backend on desktops it recognises
# (XDG_CURRENT_DESKTOP=niri is not one), otherwise safeStorage is off and
# the OAuth tokens are dropped on exit. The flag points it at gnome-keyring
# (programs.niri, unlocked at login through greetd's PAM stack).
{ inputs, ... }:
{
  den.aspects.desktop-claude-app.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.symlinkJoin {
          name = "claude-desktop";
          paths = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/claude-desktop --add-flags --password-store=gnome-libsecret
          '';
        })
      ];
    };
}
