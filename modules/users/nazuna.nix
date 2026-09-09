{ den, ... }:
{
  den.aspects.nazuna = {
    includes = [
      # account creation + wheel/networkmanager membership
      den.batteries.define-user
      den.batteries.primary-user

      # home environment
      den.aspects.home-bash
      den.aspects.home-btop
    ];

    # login shell, explicit so moving to fish later is a one-line change.
    # bashInteractive, not pkgs.bash: the latter has no readline and is not in
    # environment.shells. `user` comes from context, the name isn't hardcoded.
    nixos =
      { user, pkgs, ... }:
      {
        users.users.${user.userName}.shell = pkgs.bashInteractive;
      };
  };
}
