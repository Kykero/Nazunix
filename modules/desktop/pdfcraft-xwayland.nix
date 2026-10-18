# pdfcraft runs under XWayland until upstream fixes storytold/pdfcraft#991:
# on Wayland it misses Ctrl's release after Ctrl+wheel, so the wheel keeps
# zooming. Unsetting WAYLAND_DISPLAY makes winit fall back to X11 through
# xwayland-satellite (niri-xwayland.nix). Drop this file once the issue is
# closed and a release past 0.8.0 is in the lock.
{ inputs, ... }:
{
  den.aspects.desktop-craftapps.nixos =
    { pkgs, ... }:
    {
      programs.craftapps.apps.pdfcraft.package =
        inputs.nix-craftapps.packages.${pkgs.stdenv.hostPlatform.system}.pdfcraft.overrideAttrs
          (old: {
            postFixup = old.postFixup + ''
              wrapProgram $out/bin/pdfcraft --unset WAYLAND_DISPLAY
            '';
          });
    };
}
