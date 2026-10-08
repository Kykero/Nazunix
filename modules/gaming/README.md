# gaming

Games and their runtimes, as one den aspect `gaming` with one sub-aspect
per file under `gaming.provides`.

| File | Aspect | What it does |
| --- | --- | --- |
| `gaming.nix` | `gaming` | The full bundle: includes `steam`, `protontricks`, `prism` and `wine`. |
| `steam.nix` | `gaming._.steam` | `programs.steam` at the NixOS level (32-bit graphics, controller udev rules, Remote Play firewall ports). |
| `protontricks.nix` | `gaming._.protontricks` | winetricks for the Wine prefixes of Proton games (`programs.steam.protontricks`). |
| `prism.nix` | `gaming._.prism` | Prism Launcher for Minecraft, in the users' `home.packages`. |
| `wine.nix` | `gaming._.wine` | wine-tkg from the nix-gaming input, in the users' `home.packages`. |

## Notes

- Not part of any profile; hosts include it directly
  (`modules/hosts/<machine>/<machine>.nix`). `yamori` takes the full
  `gaming` bundle, `dazai` only `gaming._.steam` (8GB RAM).
- wine-tkg comes prebuilt from the nix-gaming cache (`nix/caches.nix`).
- Steam is unfree, allowed globally by `nix/unfree.nix`.
- X11 games under niri rely on `desktop/niri-xwayland.nix`.
