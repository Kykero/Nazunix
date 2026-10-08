# nix

Settings for Nix itself and for nixpkgs.

| File | Aspect | What it does |
| --- | --- | --- |
| `settings.nix` | `nix-settings` | Flakes and `nix-command` on, `root` and `@wheel` trusted, no channels, registry and `NIX_PATH` pinned to the flake's nixpkgs, weekly store optimisation. |
| `caches.nix` | `nix-caches` | Substituters and their keys: cache.nixos.org, nix-community, numtide (llm-agents builds such as codex and herdr) and nix-gaming (wine-tkg). |
| `unfree.nix` | `den.default` | `allowUnfree = true` on every host; home-manager shares this nixpkgs. |

## Notes

- `nix-settings` and `nix-caches` are included by `profile-base`
  (`profiles/base.nix`), so every entity, `-base` included, has them.
- `@wheel` being trusted is what lets `den-rebuild` and `den-bootstrap`
  pass `--option extra-substituters`, and lets devenv use its own caches.
- `den-bootstrap` and `den-rebuild` read the substituter list from the
  target configuration, so a cache added in `caches.nix` already serves
  the build that activates it.
