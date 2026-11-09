# Outlook as a web app: nixpkgs packages no Outlook wrapper (unlike Teams and
# WhatsApp), so Outlook on the web runs in a chromeless Chromium window
# (--app) with its own profile, isolated from the main browser. Chromium runs
# as a native Wayland client thanks to NIXOS_OZONE_WL (niri.nix).
#
# Chromium opens a link from the mail in a window of its own, never in the
# default browser. A small unpacked extension catches every window Outlook
# opens on a site outside Microsoft's mail and sign-in hosts, hands the URL
# to a native messaging host that runs xdg-open (so Zen, browser.nix), and
# closes the window. If the host cannot be reached the window stays open.
# The manifest key only pins the extension ID that the host allows; it is a
# public key, the private half was never kept.
{ ... }:
{
  den.aspects.desktop-outlook.provides.to-users.homeManager =
    { pkgs, lib, ... }:
    let
      hostName = "nazunix.outlook_links";
      extensionId = "glknojchebdjbkeikdacacndobpokeel";

      manifest = pkgs.writeText "manifest.json" (
        builtins.toJSON {
          manifest_version = 3;
          name = "Outlook links in the default browser";
          version = "1";
          key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnykIWuo0vwsLpxq+dRaVBgcqkg3raFx0ZIiFm5wdqvcO9AosNIGJo+36W6XEMKeG9tprUtgA1HMmqAZntomupK1K+AJ2UjFXiadxE9Vlcz16LOFfFlCjWliXC0QBmAeoU+hY3QUD4H/GeguOJCIj0maQa1Cz10tS2/3RdOJ4a3ygBZdm3l11HrBGlX71sOFDqukISU5diRJ8AoaxxjNyNj8GtUUfil1ViFLD3CtoppHlusIldVDGThZzl9v1+uhysDDEveUAhSEZ6iuGpNZp4rBiDVm2jKNUlxxrE1d4CCst6G8qXS83DvLzw8yosc3Auct/2g0GnqY1rJPFJvMlLwIDAQAB";
          background.service_worker = "background.js";
          permissions = [
            "webNavigation"
            "nativeMessaging"
          ];
        }
      );

      # A new window is judged once, on its first real URL. window.open("")
      # then setting location fires no onCreatedNavigationTarget, so tabs
      # created while the worker runs are also judged on their first
      # navigation. The app window itself starts on Outlook and stays.
      background = pkgs.writeText "background.js" ''
        const appHosts = new Set([
          "outlook.office.com",
          "outlook.office365.com",
          "outlook.cloud.microsoft",
          "outlook.live.com",
          "login.microsoftonline.com",
          "login.microsoft.com",
          "login.live.com",
        ]);
        const fresh = new Set();
        const judged = new Set();

        function external(url) {
          try {
            const { protocol, hostname } = new URL(url);
            return (protocol === "https:" || protocol === "http:") && !appHosts.has(hostname);
          } catch {
            return false;
          }
        }

        function handOff(tabId, url) {
          chrome.runtime.sendNativeMessage("${hostName}", { url }, () => {
            if (!chrome.runtime.lastError) chrome.tabs.remove(tabId);
          });
        }

        function judge(tabId, url) {
          if (!url || url === "about:blank" || judged.has(tabId)) return;
          judged.add(tabId);
          if (external(url)) handOff(tabId, url);
        }

        chrome.tabs.onCreated.addListener(({ id }) => fresh.add(id));
        chrome.tabs.onRemoved.addListener((id) => {
          fresh.delete(id);
          judged.delete(id);
        });

        chrome.webNavigation.onCreatedNavigationTarget.addListener(({ tabId, url }) => judge(tabId, url));

        chrome.webNavigation.onBeforeNavigate.addListener(({ tabId, frameId, url }) => {
          if (frameId === 0 && fresh.has(tabId)) judge(tabId, url);
        });
      '';

      extension = pkgs.runCommand "outlook-links-extension" { } ''
        mkdir $out
        cp ${manifest} $out/manifest.json
        cp ${background} $out/background.js
      '';

      # native messaging: a 32-bit length then JSON, on stdin and stdout
      linkHost =
        pkgs.writers.writePython3 "outlook-links-host"
          {
            # the store path of xdg-open alone is longer than a line
            flakeIgnore = [ "E501" ];
          }
          ''
            import json
            import struct
            import subprocess
            import sys

            XDG_OPEN = "${pkgs.xdg-utils}/bin/xdg-open"

            (length,) = struct.unpack("=I", sys.stdin.buffer.read(4))
            url = json.loads(sys.stdin.buffer.read(length))["url"]
            if url.startswith(("https://", "http://")):
                subprocess.Popen(
                    [XDG_OPEN, url],
                    stdin=subprocess.DEVNULL,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    start_new_session=True,
                )
            reply = json.dumps({"ok": True}).encode()
            sys.stdout.buffer.write(struct.pack("=I", len(reply)) + reply)
            sys.stdout.buffer.flush()
          '';

      outlook = pkgs.writeShellScriptBin "outlook" ''
        exec ${lib.getExe pkgs.chromium} \
          --user-data-dir="''${XDG_DATA_HOME:-$HOME/.local/share}/outlook-webapp" \
          --load-extension=${extension} \
          --app=https://outlook.office.com/mail/ "$@"
      '';
      # the Outlook logo from Papirus, copied alone so the whole theme stays
      # out of the runtime closure
      icon = pkgs.runCommand "outlook-icon.svg" { } ''
        cp ${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/ms-outlook.svg $out
      '';
    in
    {
      home.packages = [ outlook ];

      # Chromium looks for user-level hosts in the profile it runs with
      xdg.dataFile."outlook-webapp/NativeMessagingHosts/${hostName}.json".text = builtins.toJSON {
        name = hostName;
        description = "Open Outlook links in the default browser";
        path = "${linkHost}";
        type = "stdio";
        allowed_origins = [ "chrome-extension://${extensionId}/" ];
      };

      xdg.desktopEntries.outlook = {
        name = "Outlook";
        genericName = "Mail";
        exec = "outlook";
        icon = "${icon}";
        categories = [
          "Network"
          "Email"
        ];
      };
    };
}
