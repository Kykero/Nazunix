{ den, ... }:
{
  den.aspects.nazuna = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.btop ];
      };
  };
}
