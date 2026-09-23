# OneDrive mounted at ~/OneDrive with onedriver: a FUSE filesystem, not a
# sync client. Files are downloaded when opened and cached locally, nothing
# is mirrored up front.
#
# The user service mirrors upstream's onedriver@.service, written out in
# home-manager so the mount point comes from the home directory instead of
# a systemd-escaped path naming the user. It starts with the graphical
# session: the first run opens Microsoft's sign-in window, then the token
# lives in ~/.cache/onedriver, never in the repo.
#
# onedriver unmounts through the setuid fusermount3 wrapper, which
# programs.fuse provides.
{ ... }:
{
  den.aspects.desktop-onedrive = {
    nixos.programs.fuse.enable = true;

    provides.to-users.homeManager =
      { config, pkgs, ... }:
      let
        mountPoint = "${config.home.homeDirectory}/OneDrive";
      in
      {
        home.packages = [ pkgs.onedriver ];

        systemd.user.services.onedriver = {
          Unit = {
            Description = "OneDrive on demand (onedriver)";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountPoint}";
            ExecStart = "${pkgs.onedriver}/bin/onedriver ${mountPoint}";
            ExecStopPost = "/run/wrappers/bin/fusermount3 -uz ${mountPoint}";
            Restart = "on-abnormal";
            RestartSec = 3;
            RestartForceExitStatus = 2;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
  };
}
