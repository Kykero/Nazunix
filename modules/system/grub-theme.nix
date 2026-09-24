# Elegant GRUB theme (vinceliuice/Elegant-grub2-themes), variant
# mountain / float / left / light at 1080p with the NixOS logo. The repo's
# generate.sh assembles one variant from its shared assets, at build time.
{ ... }:
{
  den.aspects.grub-theme.nixos =
    { pkgs, ... }:
    let
      src = pkgs.fetchFromGitHub {
        owner = "vinceliuice";
        repo = "Elegant-grub2-themes";
        rev = "f8a8d41c8f306f8bdfae41db1a425cf0a2451477";
        hash = "sha256-4yPldMZ7g6FrGGvoF2oxvS6cGlM2X/ALX0mfq/Dax8c=";
      };
    in
    {
      boot.loader.grub = {
        theme = pkgs.runCommand "elegant-grub-theme" { } ''
          bash ${src}/generate.sh -d "$TMPDIR/themes" \
            -t mountain -p float -i left -c light -s 1080p
          cp -r "$TMPDIR/themes/Elegant-mountain-float-left-light" $out
          # `-l system` asks lsb_release for the distro; take its NixOS logo directly
          install -m 644 ${src}/assets/assets-other/other-1080p/Nixos.png $out/logo.png
        '';
        # the layout is sized for 1080p; auto if the firmware lacks the mode
        gfxmodeEfi = "1920x1080,auto";
      };
    };
}
