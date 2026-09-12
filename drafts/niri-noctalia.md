# Draft — niri-flake + Noctalia (phase 10 desktop)

Working notes for the desktop phase. Nothing here is evaluated: no local Nix,
CI is the only evaluator. Treat every snippet as a proposal to be pushed and
checked, not as a verified configuration.

## Sources

| Thing | URL |
| --- | --- |
| niri-flake | <https://github.com/sodiboo/niri-flake> |
| niri (upstream) | <https://github.com/YaLTeR/niri> |
| Noctalia (site) | <https://noctalia.dev/> |
| Noctalia (docs) | <https://docs.noctalia.dev/> |
| Noctalia (org) | <https://github.com/noctalia-dev> |
| NixOS wiki page | <https://wiki.nixos.org/wiki/Noctalia_Shell> |

---

## 1. What each piece is

**niri** — a scrollable-tiling Wayland compositor. It is the session: the thing
that owns the display, the windows and the input.

**niri-flake** (sodiboo) — packaging and module layer around niri. It ships:

* packages `niri-stable`, `niri-unstable`, `xwayland-satellite`;
* `overlays.niri`;
* `nixosModules.niri` — the session, portals wiring, the `programs.niri.*`
  options;
* `homeModules.niri` and `homeModules.config` — the user-side KDL config;
* `homeModules.stylix` — optional Stylix integration;
* a Cachix binary cache, `niri.cachix.org` (x86_64-linux only).

**Noctalia** — not a compositor, a *shell*: bar, dock, launcher, control center,
notifications, OSDs, lock screen, wallpaper-driven theming, clipboard history,
tray. It runs on top of a Wayland compositor that provides layer-shell, and
niri is one of its explicitly supported targets (with Hyprland, Sway, Scroll,
Mango, Labwc, Triad, dwl).

So the stack is:

```text
niri            compositor / session
  └── Noctalia  shell: bar, launcher, notifications, lock, theming
```

They are complementary, not alternatives. niri alone gives a bare session with
no bar and no launcher; Noctalia fills exactly that gap.

The Noctalia family also contains **Umbriel** (their own compositor) and a
**Greeter** (greetd login screen). Neither is wanted here — niri is the
compositor, and the greeter question belongs to a separate decision.

---

## 2. The cache constraint (already encoded in the repo)

`flake.nix` carries this line, currently commented out:

```nix
# niri.url = "github:sodiboo/niri-flake";   # NO follows -- keeps niri.cachix.org
```

That comment is the important part. Adding `inputs.nixpkgs.follows = "nixpkgs"`
to the niri input changes the derivation hashes and every `niri.cachix.org` hit
becomes a miss — `dazai` (8 GB laptop) would then compile a compositor from
source. The niri input must stay unfollowed.

`modules/nix/caches.nix` already lists the substituter and the public key, so
that side is done:

```nix
"https://niri.cachix.org"
"niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
```

niri-flake also exposes `niri-flake.cache.enable` in its NixOS module, which
adds the substituter itself. Since `caches.nix` already declares it
explicitly, that option should probably be set to `false` to keep a single
source of truth — **to verify** that the option name and default are still what
the README says.

Whether Noctalia has its own cache is an **open question**. If it does not, and
if it builds from source, that build cost lands on whichever machine rebuilds —
so `yamori` (the builder) should be the one to warm it.

---

## 3. Proposed file layout

The roadmap already reserves `modules/desktop/{niri,niri-home,portals}.nix` for
phase 10. Noctalia adds one more concern, so one more file:

```text
modules/desktop/niri.nix          den.aspects.desktop-niri       (nixos)
modules/desktop/niri-home.nix     den.aspects.desktop-niri-home  (homeManager, KDL)
modules/desktop/portals.nix       den.aspects.desktop-portals    (nixos)
modules/desktop/noctalia.nix      den.aspects.desktop-noctalia   (homeManager)
modules/profiles/desktop.nix      den.aspects.profile-desktop    (includes the four)
```

One concern per file, composed through `includes`, no hostname conditionals —
`dazai` and `yamori` both include `profile-desktop`, and any per-machine
divergence (scale, monitor names, keyboard layout) goes in the host directory
as its own aspect, not as an `if hostName == …` inside these files.

Sketch — shapes only, option names still to be confirmed against the modules:

```nix
# modules/desktop/niri.nix
{ ... }:
{
  den.aspects.desktop-niri.nixos = {
    programs.niri.enable = true;
    # programs.niri.package = pkgs.niri-stable;
    # niri-flake.cache.enable = false;  # caches.nix owns the substituter list
  };
}
```

```nix
# modules/desktop/noctalia.nix
{ ... }:
{
  den.aspects.desktop-noctalia.homeManager = {
    programs.noctalia = {
      enable = true;
      settings = {
        # generates ~/.config/noctalia/config.toml
      };
    };
  };
}
```

The flake inputs and the module wiring (`nixosModules.niri`,
`homeModules.niri`, Noctalia's `homeModules.default`) have to be registered
wherever den expects external modules to be plugged in — that hook needs to be
located before writing these files.

---

## 4. Noctalia versions — resolve this first

There is a v4 → v5 split and the naming changed with it:

| | v4 (deprecated) | v5 (current) |
| --- | --- | --- |
| repo | `noctalia-dev/noctalia-shell` | `noctalia-dev/noctalia` |
| option | `programs.noctalia-shell.enable` | `programs.noctalia.enable` |
| runtime | Quickshell / QML | native, no Qt/GTK dependency |

Most blog posts and dotfiles found in the wild are v4 and will not apply. There
is at least one reported breakage of exactly this kind: a `nix flake update`
moving a config from v4 to v5 and `programs.noctalia-shell` vanishing
(`noctalia-dev/noctalia` issue #3204).

**Do not copy option names from this draft into a module.** Read the current
`flake.nix` and the module source of the pinned revision, then write the file.

---

## 5. `settings` vs raw config

Both projects offer the same two doors.

* niri-flake: `programs.niri.settings` (schema-validated at build time, a real
  Nix attrset) or `programs.niri.config` (KDL string / structure).
  The README warns that `settings` is only guaranteed against the two niri
  versions the flake provides; `config` is the version-agnostic escape hatch.
* Noctalia: `programs.noctalia.settings` generates
  `~/.config/noctalia/config.toml`.

Prefer `settings` in both cases — it fails at eval time in CI, which is the only
place anything gets checked here. Fall back to the raw form only for options the
schema does not cover.

Caveat worth planning for: Noctalia is a shell with a GUI control center, so it
will want to write its own config at runtime. A fully declarative
`settings` block makes that file read-only and the in-app settings panel
becomes a lie. Decide explicitly which of the two owns the file. A reasonable
middle ground is to declare only what must be reproducible (theme source, bar
modules, keybinds) and leave the rest mutable — **to verify** whether the
home-manager module even allows a partial/mutable file.

---

## 6. Open questions

1. Where does den expect third-party NixOS/home-manager modules to be
   registered? That determines whether the desktop aspects can stay pure
   `den.aspects.*` files or need a separate wiring file.
2. `niri-flake.cache.enable` — exact name, default value, and whether disabling
   it conflicts with anything.
3. Does Noctalia publish a binary cache? If not, how long is a cold build, and
   does `dazai` ever have to do it or does `den-warm` cover it?
4. Noctalia v5 runtime dependencies (fonts, `cliphist`, screenshot/brightness
   helpers) — which are pulled by the module and which have to be added to the
   profile by hand.
5. Portals: niri-flake wires some portals itself. Overlap with a separate
   `portals.nix` needs checking before both declare the same thing.
6. Lock screen and idle: Noctalia ships a lock screen. Does it want an idle
   daemon configured alongside, and does that collide with anything in the
   session?
7. Greeter — out of scope here, but note that Noctalia has one, in case the
   display-manager decision later wants to reuse it.

---

## 7. Suggested order

1. Uncomment the `niri` input, register `nixosModules.niri` + `homeModules.niri`,
   `programs.niri.enable = true` and nothing else. Push, read `check`.
2. Confirm the cache actually hits (the `check` run's build step is the only
   evidence available).
3. `niri-home.nix` — minimal KDL: keyboard layout, one terminal keybind, outputs.
4. `portals.nix`, once the overlap with niri-flake is understood.
5. Pin Noctalia v5, add `noctalia.nix` with `enable = true` and an empty
   `settings`. Push, read `check`.
6. Fill `settings` incrementally, one commit per concern.
7. `profile-desktop`, then include it from the host entities.

One logical change per commit, push, wait for `check`, read the verdict.
`lock.yml` runs manually when the inputs change — adding niri and Noctalia is
exactly such a change.
