# Iterating in a VM

Every host in `modules/hosts.nix` boots in QEMU without touching a disk:
`modules/vm.nix` wraps each `nixosConfigurations.<name>.config.system.build.vm`
as a flake package `vm-<name>`. Use it to try a change before switching a
real machine.

There is no true hot reload of the NixOS system: a change means rebuild and
relaunch (seconds when little changed). niri's own config can be tuned live,
see [Live niri tweaks](#live-niri-tweaks-no-relaunch).

## Where it runs

A Linux machine with Nix and flakes, ideally with KVM (`/dev/kvm`). Windows
alone cannot run it.

- **`yamori` or `dazai`**: the normal place, `~/Nazunix` is already there.
  On `dazai` (8 GB), the full-profile VM takes 4 GB.
- **WSL2 with Nix** (untested): Windows 11 exposes `/dev/kvm` in WSL2 on CPUs
  with nested virtualization, and WSLg shows the QEMU window. Without
  `/dev/kvm` QEMU falls back to software emulation, too slow for a desktop.

## Run it

```bash
cd ~/Nazunix
nix run .#vm-dazai          # full profile: logs straight into niri + Noctalia
nix run .#vm-dazai-base     # -base gateway: console, autologin as nazuna
```

The packages are `vm-dazai`, `vm-yamori`, `vm-dazai-base`, `vm-yamori-base`,
one per `nixosConfigurations` entry. Arguments after `--` go to QEMU
(`nix run .#vm-dazai -- -smp 2`). RAM is set only through
`virtualisation.memorySize` (`modules/desktop/vm.nix`): a `-m` on the command
line clashes with the memory backend and QEMU refuses to start.

What the VM takes from the host config, and what it replaces:

- The Nix store is the **host's**, shared read-only over virtiofs with a
  tmpfs overlay. Nothing is copied.
- `fileSystems` (disko) and GRUB are **replaced**: the kernel boots directly,
  root is a qcow2 image. The disko layout is not exercised.
- No `hardware.nix`, no Wi-Fi. Networking is QEMU user-mode NAT, the guest
  reaches the internet.
- home-manager activates at boot as usual: niri config, ghostty, fish.
- Full profile only (`modules/desktop/vm.nix`): 4 GB RAM, 4 cores, a
  3D-capable `virtio-vga-gl` GPU (niri needs it), greetd logs `nazuna` into
  niri once at boot, sudo without password.

Keyboard: click the QEMU window to grab the keyboard so `Super` reaches niri;
`Ctrl+Alt+G` releases it.

Logging out of niri lands on the greeter, which cannot be passed (`nazuna`
has no password in the repo): relaunch the VM.

## State: the disk image

The root disk is `./<hostname>.qcow2` in the **current directory**, created
on first start and reused: `/home`, Noctalia's GUI settings and anything
written in the guest survive a relaunch.

- `dazai` and `dazai-base` share `hostName = "dazai"`, so both use
  **`dazai.qcow2`**. Same for `yamori`. Delete it when switching between
  the two.
- Start from scratch: `rm dazai.qcow2`.
- Keep images elsewhere: `NIX_DISK_IMAGE=~/vms/dazai.qcow2 nix run .#vm-dazai`.

## Files between host and guest

`$SHARED_DIR` on the host (default `$TMPDIR/xchg`, a per-run temp dir) is
`/tmp/shared` in the guest:

```bash
SHARED_DIR=$PWD/share nix run .#vm-dazai
```

Other variables read by the start script: `QEMU_OPTS` (extra QEMU flags),
`QEMU_KERNEL_PARAMS` (extra kernel command line), `QEMU_NET_OPTS` (user-mode
network options, e.g. port forwards).

## The loop

1. edit a module under `modules/`
2. power off the VM (Noctalia's session menu, `Ctrl+Alt+Delete`, or close
   the QEMU window)
3. `nix run .#vm-dazai` again: only what changed rebuilds, the new system
   boots on the same `dazai.qcow2`

Once it looks right, commit, push and read the `check` run as usual. `check`
evaluates the real toplevels, not the VM variant: a mistake inside
`virtualisation.vmVariant` only shows when the VM is built.

### Live niri tweaks (no relaunch)

niri reloads `config.kdl` as soon as the file changes. home-manager links it
read-only from the store, so for quick value hunting (gaps, colors, window
rules) swap the link for a writable copy inside the VM:

```bash
cp --remove-destination "$(readlink -f ~/.config/niri/config.kdl)" ~/.config/niri/config.kdl
chmod u+w ~/.config/niri/config.kdl
vim ~/.config/niri/config.kdl    # every save applies immediately
niri validate                    # optional parse check
```

Then port the values back into `modules/desktop/niri-*.nix`. Before the next
launch delete the copy (`rm ~/.config/niri/config.kdl`) or reset the image:
home-manager refuses to overwrite a regular file there and its activation
fails.

Noctalia works the same way without any trick: `~/.config/noctalia/*.toml`
is hot-reloaded (see `drafts/noctalia/config.toml`).
