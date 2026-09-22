# Nazunix

Declarative NixOS for a small personal fleet (`yamori` desktop, `dazai`
laptop, user `nazuna`), built on flake-parts, import-tree and the den
framework. Desktop: niri + Noctalia, AZERTY. Architecture and phase status:
[docs/ROADMAP.md](docs/ROADMAP.md).

The repo is the installer: `den-bootstrap` runs from a NixOS live USB, wipes
the chosen disk, installs the `-base` gateway and then the full profile.

## Installing from a USB stick

### 1. Prepare the stick

Any NixOS ISO works: the **graphical** one (KDE desktop, easy Wi-Fi, open a
terminal) or the **minimal** one (console only). The graphical installer is
never used; only the terminal is. Write the ISO to a USB stick with Ventoy,
Rufus (dd mode) or `dd`.

Optional second stick (or a Ventoy data partition next to the ISO): a
`nazunix-keys/` directory. It is picked up automatically, nothing in it
enters the repo.

| File | Role |
|---|---|
| `id_ed25519`, `id_ed25519.pub` | user SSH key, used to push and sign commits |
| `ssh_host_ed25519_key`, `.pub` | optional, pre-seeded sshd host key so the machine identity is stable |
| `git.env` | optional, `GIT_NAME=…` and `GIT_EMAIL=…` (GitHub noreply address). With it, the generated host files are committed and pushed from the ISO |

`NAZUNIX_KEYS=/path` points at the directory explicitly if auto-detection
misses it.

### 2. Boot the stick

Boot from USB (F12 / firmware boot menu, Secure Boot off). Connect to the
network: the network icon on the graphical ISO, `nmtui` on the minimal one.

Keyboard: the live system is QWERTY. Switch before typing anything that
matters (the password at the end):

```bash
setxkbmap fr   # graphical ISO, in the terminal
loadkeys fr    # minimal ISO
```

### 3. Run the installer

```bash
sudo -i
nix --extra-experimental-features "nix-command flakes" run github:Kykero/Nazunix#den-bootstrap
```

It asks, in order:

1. **host**: an existing one (`dazai`, `yamori`) or "new host" plus a name
2. **user**: `nazuna`
3. **disk**: the internal disks are listed with path, size and model; the
   live USB is excluded. **The chosen disk is wiped entirely** (GPT, 1 GB
   ESP, btrfs). Dual boot only works with a second physical disk: pick the
   one without Windows, check the model and size in the list.
4. **also install the full profile right after `-base`?** answer **yes** to
   get the desktop (niri, Noctalia, greeter) in the same run. `-base` stays
   in the GRUB menu as the fallback generation.

It then generates `hardware.nix`, patches `disko.nix` with the chosen disk,
shows the diff, evaluates both toplevels **before** touching the disk, and
asks for the irreversible confirmation. Caches are passed to `nixos-install`
automatically. It ends with `passwd <user>` and never reboots by itself.

### 4. First boot

Remove the stick, reboot. The Noctalia greeter shows up; the session is
"Niri". Noctalia has no declarative config: everything is set from its GUI.

If the ISO could not push (no `git.env`), the checkout with the generated
host files is in `~/Nazunix`, staged:

```bash
cd ~/Nazunix && git status
git commit -m "feat(<host>): hardware and disk from den-bootstrap"
git push                            # CI evaluates the new host
```

If the full profile was not installed from the ISO (answered no, or it
failed), from the `-base` system:

```bash
nix run ~/Nazunix#den-warm          # pull the full closure from the caches
nh os switch                        # switch to <host> (full)
```

Day-2 rebuilds:

```bash
nix run ~/Nazunix#den-rebuild       # ff-only pull + nh os switch
```

## Keyboard (AZERTY) in niri

niri binds match the unshifted keysym, so the defaults are transposed in
`modules/desktop/niri-binds.nix`: workspaces on `Mod` + the number row as
printed (`& é " ' ( - è _ ç`), hotkey overlay on `Mod+Shift+:`, column
width on `Mod+)` / `Mod+=`, consume/expel on `Mod+^` / `Mod+$`. `Mod+T`
terminal, `Mod+D` Noctalia launcher, `Super+Alt+L` lock.
