# Sunshine: game stream host for Moonlight clients. The NixOS module brings
# uinput (virtual mouse, keyboard, gamepads), Sunshine's udev rules, Avahi
# so clients discover the host, and a user service. autoStart is off: at
# launch Sunshine probes every capture backend, and the XDG portal probe
# pops a screen-share dialog, so the service is started on demand
# (systemctl --user start sunshine). capSysAdmin wraps the binary with
# cap_sys_admin for KMS capture; encoding goes through VA-API on the AMD
# GPU (mesa, no extra driver).
# settings is left empty so Sunshine keeps its own config, edited from the
# web UI (https://localhost:47990), where the admin account is created and
# clients are paired; no credential lands in the repo.
{ ... }:
{
  den.aspects.gaming.provides.sunshine.nixos.services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true; # TCP 47984-47990, 48010; UDP 47998-48000, 48002, 48010
  };
}
