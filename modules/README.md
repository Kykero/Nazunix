# modules/

Every Nix file of the configuration. `flake.nix` hands this directory to
import-tree, which loads every `.nix` file under it as a flake-parts module:
there is no import list to maintain, and a new file is picked up as soon as
it exists. Files that are not `.nix` (these READMEs, the Noctalia TOML
snapshots, `omo-graph.sh`) are ignored by import-tree.

## Folders

| Folder | Contents |
|---|---|
| [apps/](apps/README.md) | `den-bootstrap`, `den-rebuild`, `den-warm`, `den-noctalia-save`: the install and day-2 commands |
| [desktop/](desktop/README.md) | the graphical session: niri, Noctalia, greeter and desktop apps |
| [gaming/](gaming/README.md) | the `gaming` bundle and its sub-aspects (Steam, Wine, Prism, protontricks) |
| [homes/](homes/README.md) | home-manager aspects, split into `ai/`, `shell/` and `tui/` |
| [hosts/](hosts/README.md) | per-machine implementation: hardware, disk layout, machine-only tweaks |
| [neovim/](neovim/README.md) | Neovim built with nvf from the `vimzuna` namespace |
| [nix/](nix/README.md) | Nix settings, binary caches, unfree packages |
| [profiles/](profiles/README.md) | `profile-base`, `profile-full` and the bundles they include |
| [schema/](schema/README.md) | the host `profile` option and the pointcut that applies it |
| [shell/](shell/README.md) | git, gh and glab |
| [system/](system/README.md) | boot (GRUB EFI, theme, Windows dual boot), zram, keyboard, Tailscale, devenv, laptop power |
| [users/](users/README.md) | user aspects (`nazuna`) |

## Loose files

| File | What it does |
|---|---|
| `defaults.nix` | imports den's flake module; `stateVersion`, home-manager as a NixOS module for every user (`useGlobalPkgs`), the hostname battery on every host |
| `hosts.nix` | the sole registry of machines (`den.hosts`); nothing else declares a host |
| `devshell.nix` | `nix develop`: scripting, Nix linting and debugging tools, kept out of the host closures |
| `nh.nix` | `nix run .#<host>` flake packages through nh, and the `nix-nh` aspect (`programs.nh` with scheduled cleaning) |
| `vm.nix` | a `vm-<host>` package for every `nixosConfigurations` entry, and autologin inside VMs ([docs/vm.md](../docs/vm.md)) |

## How it composes

Everything is a den aspect: a named bundle of `nixos`, `homeManager` (or
other class) settings plus `includes` of other aspects. Nothing uses
`imports` chains or hostname conditionals.

- `hosts.nix` declares each host and its users.
- A host includes the aspect of the same name, defined in
  `hosts/<machine>/`, which pulls in the machine's hardware aspect.
- `schema/` gives every host a `profile` (`base` or `full`) and includes the
  matching `profile-<name>` aspect automatically.
- `profiles/` turn a profile into a list of feature aspects from the other
  folders.
- A user listed on a host gets its aspect from `users/`; `den.default`
  (`defaults.nix`, `nix/unfree.nix`) applies to every host.

Adding a feature means adding a file that defines an aspect, then including
it from a profile, a host or a user.
