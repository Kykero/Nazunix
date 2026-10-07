# Draft — ArtCraft apps (PhotoCraft, PrintCraft)

Working notes on packaging two of the ArtCraft "Crafting Apps"
(https://getartcraft.com/apps): PhotoCraft, an image editor, and PrintCraft,
a PDF workbench (read, organize, combine, split, secure). Both are native
Rust apps, open source, early alpha, with Linux builds.

Status: on hold, nothing added. Waiting for a nixpkgs package or an
upstream flake.

## Where things stand (2026-10-07)

- **nixpkgs**: neither app is packaged.
- **Upstream** (`storytold`): no flake. Each app ships a relocatable Linux
  tarball per arch on its GitHub releases:
  `https://github.com/storytold/<app>/releases/download/v<version>/<app>-<version>-linux-<arch>.tar.gz`
  (`bin/`, `share/applications`, icons, metainfo).
- **Community flake**: `Hy4ri/artcraft-flake`, created 2026-10-06, one star.
  One overlay for every Crafting App, built from the upstream tarballs with
  pinned hashes (`version.json`, refreshed by `update-version.sh`). Not
  adopted: an unknown maintainer would sit in the inputs.

## If we package it ourselves

The derivation is small: `fetchurl` the tarball, `autoPatchelfHook`, copy
`bin` and `share`, and put the dlopen()ed libraries in
`runtimeDependencies`: alsa-lib, dbus, libGL, libxkbcommon, libx11, libxcb,
libxcursor, libxi, vulkan-loader, wayland. One file per concern would give a
package plus a `desktop-artcraft` aspect included by the desktop profile.
Cost: version and hash bumps by hand.

## Revisit when

- a `photocraft` / `printcraft` attribute lands in nixpkgs, or
- `storytold` publishes a flake.
