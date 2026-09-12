# Nazunix — roadmap

Ground rules (dendritic style, privacy, filenames, registry) are not repeated
here — see `CLAUDE.md` at the repo root.

## 1. Purpose

A fully declarative, reproducible NixOS configuration for a small personal
fleet, public on GitHub under the Kykero pseudonym.

**Success criterion:** from a minimal NixOS live ISO, a machine goes from
blank disk to full desktop in ~6 commands, with a single choice (which
entity) plus one wipe confirmation, because the repo *is* the installer.

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

### Phases 0–6

| Phase | Content | Status |
|---|---|---|
| 0 | den skeleton, `hosts.nix`, `check.yml` (on every push), `lock.yml` (manual only) | done |
| 1 | `profile` schema + pointcut | done |
| 2 | `modules/nix/{settings,caches}.nix`, nh | done |
| 3 | `profiles/{base,full}.nix`, `dazai-base` / `yamori-base` entities | done |
| 4 | disko btrfs layout, GRUB, monthly scrub, zram (dazai); placeholder deleted | done |
| 5 | `modules/users/nazuna.nix`, `modules/homes/{bash,btop}.nix`: `define-user`, `primary-user`, bash login shell, home-manager bash + btop | done |
| 6 | `modules/apps/{bootstrap,warm,rebuild}.nix`: `den-bootstrap` (gum installer from the live ISO; generates `hardware.nix`, renders a new host from `templates/host/` or patches an existing host's disk device), `den-warm` (pull the full closure via `nh os build`), `den-rebuild` (ff-only pull + `nh os switch`); CI builds all three | done |

### Phases 7–11

| Phase | Files | Content | Gate |
|---|---|---|---|
| **7. Install yamori** | `modules/hosts/yamori/hardware.nix` | `den-bootstrap` → pick `yamori`, its disk → review generated files → install → reboot → commit + push the generated files → `nh os switch` to `yamori` | machine boots, CI green |
| **8. Install dazai** | `modules/hosts/dazai/hardware.nix` | same with `dazai`, then `den-warm` before `nh os switch` | machine boots, CI green |
| **9. Secrets** | `modules/secrets/sops.nix`, `.sops.yaml`, `secrets/*.yaml` | `ssh-to-age` from host keys post-boot, `hashedPasswordFile` replaces the password typed at install time | switch on real hardware |
| **10. Desktop** | `modules/desktop/{niri,niri-home,portals}.nix`, `modules/homes/mailspring.nix` | niri session in `nixos`, KDL config in `homeManager`, xdg portals; Mailspring as the email client (home aspect, account setup stays out of the repo) | CI eval + build (**niri cache required**) |
| **11. Fleet** | `modules/nix/distributed.nix` | `yamori` accepts builds (`builder`), `dazai` delegates (`build-client`), user `nixremote`, `ssh-ng`, resolved via `yamori.local` | real cross-machine test |

`yamori` is installed **before** `dazai`: the 8 GB laptop should not be left
compiling whatever the caches miss, with no disk swap yet.

No password ever lives in the repo: `den-bootstrap` ends with
`nixos-enter --root /mnt -c 'passwd <user>'`, the NixOS manual's recommended
way, and phase 9 moves that password into sops.

## 5. Known gaps

- **`hardware.nix`** does not exist yet for either machine. `den-bootstrap`
  generates it at install time from `nixos-generate-config --no-filesystems
  --show-hardware-config`, keeping only kernel modules and microcode, and
  shows it before anything is written to disk. **Never `nixos-facter`** — it
  embeds MACs and serials in `facter.json`. Evaluation passes without the
  file; booting reliably does not.
- **disko device paths are placeholders** (`/dev/nvme0n1`) in both
  `disko.nix` files until the first real install: `den-bootstrap` lists the
  machine's disks and rewrites the device with the one you pick.

## 6. Reference install sequence

UX that the phase 6 scripts (`den-bootstrap`, `den-warm`, `den-rebuild`)
automate. From the live ISO, as root:

```bash
sudo -i
nix --extra-experimental-features "nix-command flakes" run github:Kykero/Nazunix#den-bootstrap
```

`den-bootstrap` asks for the host (an existing one, or "new host" plus a
name), the user (among `modules/users/*.nix`) and the target disk (the live
USB is excluded). It then generates `hardware.nix` from
`nixos-generate-config`, renders a new host's `<host>.nix` and `disko.nix`
from `templates/host/` (or patches the disk device of an existing host's
`disko.nix` in place), shows the staged diff, evaluates the
`-base` entity **before** touching the disk, and only then asks for the
irreversible confirmation. Caches are burned in with `--option` flags read
from the evaluated config — nothing re-typed by hand. It ends by asking for
the user's password and never reboots by itself.

### Keys from the USB stick

Optionally, a `nazunix-keys/` directory on removable media (a second stick,
or a Ventoy data partition next to the ISO — a dd-written ISO is read-only)
is picked up automatically; `NAZUNIX_KEYS=/path` points at it explicitly.
Nothing in it ever enters the repo:

| File | Role |
|---|---|
| `id_ed25519`, `id_ed25519.pub` | user SSH key: git push and commit signing. Installed to `/root/.ssh` on the ISO and to `/home/<user>/.ssh` on the target, with GitHub's published host key in `known_hosts` |
| `ssh_host_ed25519_key`, `.pub` (optional) | pre-seeded sshd host key, so the machine identity — and the age key phase 9 derives from it — is stable from the first boot |

Nothing is committed from the ISO: the checkout with the generated files
lands in `/home/<user>/Nazunix`. After removing the media and rebooting, log
in and finish from the machine:

```bash
cd ~/Nazunix && git status          # generated host files, staged
git commit -m "feat(<host>): hardware and disk from den-bootstrap"
git push                            # CI evaluates the new host
nix run ~/Nazunix#den-warm          # needed on dazai, harmless on yamori
nh os switch
```

### Adding a machine

Same command, pick "new host", give it a name. `den-bootstrap` registers
`<host>` and `<host>-base` in `modules/hosts.nix` (above its marker line),
creates `modules/hosts/<host>/{<host>,disko,hardware}.nix`, includes zram
when the machine has less than 16 GiB of RAM, and installs `<host>-base`.
Commit and push after the first boot, exactly as above.

Day-2 rebuilds pull the latest `main` fast-forward-only and switch:

```bash
nix run /home/nazuna/Nazunix#den-rebuild
```

## 7. Still open

- Third machine: name and role undecided.
- LUKS reinstall: planned, not scheduled.
- Snapshots (snapper vs btrbk): deferred until both machines are up.
- `yamori` disk layout: encryption arbitration differs from the laptop (it
  never leaves the flat).
