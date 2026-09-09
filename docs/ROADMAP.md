# Nazunix — roadmap

Ground rules (dendritic style, privacy, filenames, registry) are not repeated
here — see `CLAUDE.md` at the repo root.

## 1. Purpose

A fully declarative, reproducible NixOS configuration for a small personal
fleet, public on GitHub under the Kykero pseudonym.

**Success criterion:** from a minimal NixOS live ISO, a machine goes from
blank disk to full desktop in ~6 commands, with zero interactive choices,
because the repo *is* the installer.

## 2. Machines / entities

| Entity        | Machine | Role                                    |
|---------------|---------|------------------------------------------|
| `yamori`      | desktop | 32 GB RAM, 2 TB NVMe — builder          |
| `yamori-base` | desktop | same machine, minimal profile (install) |
| `dazai`       | laptop  | 8 GB RAM, 256 GB NVMe                   |
| `dazai-base`  | laptop  | same machine, minimal profile (install) |
| (third box)   | TBD     | undecided                               |

Single user account: `nazuna`.

## 3. Architecture summary

**Stack:** `nixos-unstable` · `flake-parts` · `import-tree` · **den** (flake
module) · **home-manager as a NixOS module** (not standalone, so a VM boots
the complete environment) · **disko** · sops-nix (later) · niri-flake (later).
Every input `follows` nixpkgs except `niri` — no `follows` there, or the
8 GB laptop loses `niri.cachix.org` and compiles a compositor from source.

**Two-profile system:** a schema option `profile` (`base` | `full`, default
`full`) plus a pointcut that turns the option value into the matching
aspect — nothing wired per host by hand. `base` is the install gateway
(caches pre-configured, minimal packages, bootable); `full` is the real
desktop environment. `dazai-base`/`dazai` and `yamori-base`/`yamori` are two
entities of the same machine, sharing one hardware aspect (`dazai-hw`,
`yamori-hw`). The `-base` entity exists because during `nixos-install` the
target `nix.conf` doesn't exist yet, so caches must be passed as `--option`
flags once; installing `-base` first burns the caches in, so every rebuild
after that needs no ceremony.

**Storage (disko):** GPT · 1 GB FAT32 ESP · btrfs over the rest · subvolumes
`@root @home @nix @log @swap` · `compress=zstd:1` (except `@swap`) · 8 GB
swapfile on `@swap` · GRUB EFI (`nodev`) · systemd initrd · monthly btrfs
scrub. No LUKS yet — deliberate; a reinstall with encryption is planned once
the setup is validated. `dazai` additionally gets zram (50% zstd, priority
over disk swap, tuned sysctls, `boot.tmp.useTmpfs = false`); `yamori` gets
none — 32 GB is enough.

**GC:** `nh clean` via `programs.nh`, not `nix.gc`.

**CI as sole evaluator:** there is no local Nix install; GitHub Actions is
the only place anything gets evaluated or built.
- `check.yml` runs on every push to `main`, on pull requests, and on
  `workflow_dispatch`. It imports the substituters/trusted keys straight out
  of the flake's own `nix.settings`, then evaluates the toplevel of every
  `nixosConfigurations` entry.
- `lock.yml` runs manually only (`workflow_dispatch`), when a flake input
  changes. It runs `nix flake update`, commits and pushes `flake.lock` if it
  changed, and — because a push made with the default `GITHUB_TOKEN` does not
  trigger `on: push` — explicitly dispatches `check.yml` on `main` afterwards
  so the new lock still gets evaluated.

## 4. Status (as of 2026-09-09)

### Phases 0–5

| Phase | Content | Status |
|---|---|---|
| 0 | den skeleton, `hosts.nix`, `check.yml` (on every push), `lock.yml` (manual only) | done |
| 1 | `profile` schema + pointcut | done |
| 2 | `modules/nix/{settings,caches}.nix`, nh | done |
| 3 | `profiles/{base,full}.nix`, `dazai-base` / `yamori-base` entities | done |
| 4 | disko btrfs layout, GRUB, monthly scrub, zram (dazai); placeholder deleted | done |
| 5 | `modules/users/nazuna.nix`, `modules/homes/{bash,btop}.nix`: `define-user`, `primary-user`, bash login shell, home-manager bash + btop | done |

### Phases 6–11

| Phase | Files | Content | Gate |
|---|---|---|---|
| **6. Apps** | `modules/apps/{bootstrap,warm,rebuild}.nix` | `den-bootstrap` interactive installer (**gum**, single question: which entity), `den-warm`, rebuild helper | CI build |
| **7. Install yamori** | — | disko → `nixos-install .#yamori-base` with `--option` caches → boot → `switch .#yamori` | machine boots |
| **8. Install dazai** | — | same, then `den-warm`, then full | machine boots |
| **9. Secrets** | `modules/secrets/sops.nix`, `.sops.yaml`, `secrets/*.yaml` | `ssh-to-age` from host keys post-boot, `hashedPasswordFile` replaces the temporary `initialPassword` | switch on real hardware |
| **10. Desktop** | `modules/desktop/{niri,niri-home,portals}.nix`, `modules/homes/mailspring.nix` | niri session in `nixos`, KDL config in `homeManager`, xdg portals; Mailspring as the email client (home aspect, account setup stays out of the repo) | CI eval + build (**niri cache required**) |
| **11. Fleet** | `modules/nix/distributed.nix` | `yamori` accepts builds (`builder`), `dazai` delegates (`build-client`), user `nixremote`, `ssh-ng`, resolved via `yamori.local` | real cross-machine test |

`yamori` is installed **before** `dazai`: the 8 GB laptop should not be left
compiling whatever the caches miss, with no disk swap yet.

A temporary `initialPassword` is added just before phase 7 (needed to log
into the freshly installed system before secrets exist) and is removed in
phase 9, once `hashedPasswordFile` from sops is available.

## 5. Known gaps

- **`hardware.nix`** does not exist yet for either machine. It requires
  booting a live USB on each box, running `nixos-generate-config
  --no-filesystems --show-hardware-config`, and hand-transcribing the ~15
  useful lines (initrd kernel modules, `boot.kernelModules`,
  `hardware.cpu.*.updateMicrocode`) into `modules/hosts/<machine>/hardware.nix`.
  **Never `nixos-facter`** — it embeds MACs and serials in `facter.json`.
  Evaluation passes without it; booting reliably does not.
- **disko device paths are TODO** in `modules/hosts/dazai/disko.nix` and
  `modules/hosts/yamori/disko.nix` (currently `/dev/nvme0n1`, marked to
  confirm with `lsblk` from the live ISO on each box before install).

## 6. Reference install sequence

Target UX that the phase 6 scripts (`den-bootstrap`, `den-warm`) automate:

```bash
sudo -i
nix-shell -p git
git clone https://github.com/Kykero/Nazunix /tmp/cfg && cd /tmp/cfg
nix run github:nix-community/disko -- --mode disko --flake .#dazai-base   # ERASES THE DISK
nixos-install --flake .#dazai-base --no-root-password \
  --option extra-substituters "..." --option extra-trusted-public-keys "..."
reboot
sudo nixos-rebuild switch --flake .#dazai
```

The `--option extra-substituters` / `--option extra-trusted-public-keys`
values come straight from `modules/nix/caches.nix` — they are only passed by
hand this once, for the `-base` install, because the target `nix.conf`
doesn't exist yet.

## 7. Still open

- Third machine: name and role undecided.
- LUKS reinstall: planned, not scheduled.
- Snapshots (snapper vs btrbk): deferred until both machines are up.
- `yamori` disk layout: encryption arbitration differs from the laptop (it
  never leaves the flat).
