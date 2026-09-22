# niri session: the compositor itself, from sodiboo/niri-flake.
# The flake's NixOS module registers the wayland session, polkit, gnome-keyring,
# xdg portals (gnome) and, because home-manager is a NixOS module here, injects
# its `homeModules.config` into every user -- `programs.niri.settings` lives in
# the users' homeManager class (see niri-home.nix, niri-binds.nix).
{ inputs, ... }:
{
  den.aspects.desktop-niri.nixos =
    { pkgs, ... }:
    {
      imports = [ inputs.niri.nixosModules.niri ];

      programs.niri.enable = true;

      # modules/nix/caches.nix owns the substituter list; the module would add
      # the same entries a second time.
      niri-flake.cache.enable = false;

      # the default binds call brightnessctl (XF86MonBrightness*) and wpctl
      # (wireplumber, pulled by pipewire in audio.nix)
      environment.systemPackages = [ pkgs.brightnessctl ];
    };
}
