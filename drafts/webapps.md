# Draft — declarative web apps

Working notes for turning chosen websites into standalone desktop apps.
Nothing here is evaluated: CI is the only evaluator. Treat every snippet as
a proposal to be pushed and checked, not as a verified configuration.

Status: idea, not implemented. The site list is still to be chosen.

## What is reproducible

The launcher is: the desktop entry, the command line, the icon (pinned by
hash). The site itself and the session (cookies, sign-ins) are not; they
live in a per-app profile directory, imperative state like any other app.

## Approach: Chromium `--app` + `xdg.desktopEntries`

One aspect, `desktop-webapps` (`modules/desktop/webapps.nix`), holding a
plain attrset of sites. Adding a site is one line.

```nix
webapps = {
  example = {
    url = "https://example.com";
    icon = pkgs.fetchurl { url = "https://example.com/favicon.png"; hash = "sha256-…"; };
  };
};
```

Each entry becomes a Home Manager `xdg.desktopEntries.<name>` (so it shows
in the Noctalia launcher) running:

```
chromium --app=<url> --user-data-dir=$HOME/.local/share/webapps/<name>
```

- `--app` gives a bare window: no tabs, no address bar, its own niri window.
- `--user-data-dir` isolates each site: separate sessions, and deleting the
  directory resets that app.
- Native Wayland comes from `NIXOS_OZONE_WL` (`niri.nix`), nothing to add.
- niri window rules can target an app: the Wayland app-id is derived from
  the URL. Check the actual value on the machine before writing a rule.

Browser: `ungoogled-chromium`, or `chromium` if Google sync is wanted. Either
is a new package; Zen stays the main browser.

## Rejected

| Option | Why not |
| --- | --- |
| Zen / Firefox | Firefox dropped site-specific browsers, no real app window |
| Nativefier | abandoned upstream, removed from nixpkgs |
| Pake (Tauri) | one binary per site, heavy to package in Nix for little gain |
| Epiphany (GNOME Web) | web apps are created by clicking, nothing declarative |

## Open questions

- Which sites.
- `ungoogled-chromium` or `chromium`.
- Whether WhatsApp and Teams move here instead of their Electron wrappers.
