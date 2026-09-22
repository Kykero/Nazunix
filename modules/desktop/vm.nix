# Full-profile VM (`nix run .#vm-<host>`, docs/vm.md): everything sits under
# virtualisation.vmVariant, so real machines are unaffected.
#
# greetd owns tty1, so vm-autologin's getty override never runs here: use
# greetd's own initial_session. Setting it flips services.greetd.restart to
# false; after logging out of niri the greeter can't be passed (no password
# in the repo), relaunch the VM. hardware.graphics is already on through
# programs.niri -> services.graphical-desktop.
{ ... }:
{
  den.aspects.desktop-vm.nixos.virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096; # also sizes the memfd backend: never pass -m to QEMU
      cores = 4;
      # niri needs 3D acceleration
      qemu.options = [
        "-vga none"
        "-device virtio-vga-gl"
        "-display gtk,gl=on"
      ];
    };

    services.greetd.settings.initial_session = {
      user = "nazuna";
      command = "niri-session";
    };

    # nazuna has no password in the VM
    security.sudo.wheelNeedsPassword = false;
  };
}
