# fish is every user's login shell, on every host (base and full).
# den.batteries.user-shell sets users.users.<name>.shell = pkgs.fish, the
# NixOS programs.fish.enable its assertion requires, and HM programs.fish.enable.
# Attached to the user entity kind, so no user is named.
{ den, ... }:
{
  den.aspects.home-fish = {
    includes = [ (den.batteries.user-shell "fish") ];

    homeManager.programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
      '';
      # `..` needs no alias: fish cds into a bare directory path
      shellAliases = {
        ll = "ls -alh";
        la = "ls -A";
      };
    };
  };

  den.schema.user.includes = [ den.aspects.home-fish ];
}
