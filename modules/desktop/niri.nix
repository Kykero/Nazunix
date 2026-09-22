# niri session: the compositor comes from nixpkgs (pkgs.niri, cache.nixos.org)
# through nixpkgs' own programs.niri module, which registers the wayland
# session, portals (gnome + gtk), gnome-keyring and polkit.
# niri-flake is only used for its home-manager settings module
# (niri-home.nix): its packaged niri lags upstream and no longer builds
# against current nixpkgs.
{ ... }:
{
  den.aspects.desktop-niri.nixos =
    { pkgs, ... }:
    {
      programs.niri.enable = true;

      # the default binds call brightnessctl (XF86MonBrightness*), playerctl
      # (XF86Audio{Play,Stop,Prev,Next}) and wpctl (wireplumber, via pipewire
      # in audio.nix)
      environment.systemPackages = with pkgs; [
        brightnessctl
        playerctl
      ];
    };
}
