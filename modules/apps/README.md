# apps

Shell scripts packaged as flake packages (`perSystem.packages`), not den
aspects. They are not on `PATH`: run them with `nix run <flake>#<name>`.

| File | Package | What it does |
| --- | --- | --- |
| `bootstrap.nix` | `den-bootstrap` | Interactive installer run as root from the NixOS live ISO: picks or creates a host, user and disk, writes `hardware.nix`, partitions with disko and installs `<host>-base` (optionally the full `<host>` on top). |
| `warm.nix` | `den-warm` | `nh os build` once after the first `-base` boot, so the full profile's closure is pulled from the caches before the first switch. |
| `rebuild.nix` | `den-rebuild` | Day-2 update: refuses local changes, runs `den-noctalia-save`, rebases onto `origin/main`, pushes the snapshot, then `nh os switch` with the flake's caches passed as options. |
| `noctalia-save.nix` | `den-noctalia-save` | Exports this machine's Noctalia config to `modules/desktop/noctalia/<host>.toml` and commits it when it changed. Skipped on hosts that never ran Noctalia. |

## Notes

- Order on a new machine: `den-bootstrap` from the ISO, reboot into
  `<host>-base`, `den-warm`, then `nh os switch` (or let `den-bootstrap`
  install the full profile in the same run). Afterwards, `den-rebuild`.
- `den-bootstrap` renders new hosts from `templates/host/*.in` and splices
  them into `modules/hosts.nix` above the
  `den-bootstrap inserts new hosts above this line` marker. It only stages
  the result, unless `nazunix-keys/git.env` on removable media lets it
  commit and push from the ISO. Key files never enter the repo.
- `den-rebuild` and `den-noctalia-save` find the checkout through
  `NH_OS_FLAKE` or `NH_FLAKE` (set by `programs.nh`, `modules/nh.nix`).
- The Noctalia snapshots are the seeds read by `desktop/noctalia.nix`.

See [docs/install.md](../../docs/install.md) and
[docs/den-rebuild.md](../../docs/den-rebuild.md).
