# Outer Wilds GRUB theme (Terofale/outer-wilds-grub-theme, from the
# Gorgeous-GRUB collection). The repo ships two layouts; the 1080p one is
# used and GRUB is asked for that mode. Its install.sh picks the language by
# swapping commented `text` lines in theme.txt; the same sed selects French.
{ ... }:
{
  den.aspects.grub-theme.nixos =
    { pkgs, ... }:
    let
      src = pkgs.fetchFromGitHub {
        owner = "Terofale";
        repo = "outer-wilds-grub-theme";
        rev = "e2b7c015480bd26c688a1bc7d070301c4425ba04";
        hash = "sha256-XPVUbNzR8DIIJLdw7yQ9jNekJwerXVm55fvNAxfW1jQ=";
      };
    in
    {
      boot.loader.grub = {
        theme = pkgs.runCommand "outer-wilds-grub-theme" { } ''
          cp -r ${src}/theme-files-1080p $out
          chmod -R u+w $out
          sed -i -r \
            -e '/^\s+# EN$/{n;s/^(\s*)/\1# /}' \
            -e '/^\s+# FR$/{n;s/^(\s*)#\s*/\1/}' \
            $out/theme.txt
        '';
        # the layout is sized for 1080p; auto if the firmware lacks the mode
        gfxmodeEfi = "1920x1080,auto";
      };
    };
}
