# Wine for non-Steam games: wine-tkg from nix-gaming (staging plus TKG's
# gaming patches), served prebuilt by the nix-gaming cache (nix/caches.nix).
{ inputs, ... }:
{
  den.aspects.gaming.provides.wine.provides.to-users.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.wine-tkg ];
    };
}
