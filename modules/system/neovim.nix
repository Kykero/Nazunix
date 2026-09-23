# Neovim from Vimzuna (github:Kykero/Vimzuna), on every host and profile.
# Vimzuna builds its nvf config into packages: `default` is the `nvim`
# binary, `ide` the `vimzuna` command (a zellij session around nvim, with
# its own bundled zellij config). `latex` (texlive-full) is left out.
{ inputs, ... }:
{
  den.aspects.neovim.nixos =
    { pkgs, ... }:
    let
      vimzuna = inputs.vimzuna.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      environment.systemPackages = [
        vimzuna.default
        vimzuna.ide
      ];
      environment.variables.EDITOR = "nvim";
    };
}
