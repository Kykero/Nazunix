# OpenAI's desktop app for ChatGPT and Codex, from llm-agents (numtide):
# the prebuilt release, repackaged, signed in with the ChatGPT
# subscription. Its wrapper turns on native Wayland from NIXOS_OZONE_WL
# (niri.nix). Unfree under llm-agents' own licence, no allowUnfree needed.
#
# Same safeStorage fix as claude-app.nix: Electron does not recognise niri
# as a desktop, so it is told to keep its tokens in gnome-keyring.
{ inputs, ... }:
{
  den.aspects.desktop-codex-app.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.symlinkJoin {
          name = "chatgpt";
          paths = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.chatgpt ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/chatgpt --add-flags --password-store=gnome-libsecret
          '';
        })
      ];
    };
}
