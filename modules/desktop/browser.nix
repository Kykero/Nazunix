# Zen Browser for every user of a desktop host (profile-desktop includes this).
# zen-browser-flake repackages the upstream release binaries (no compile) and
# ships a home-manager module built on home-manager's mkFirefoxModule, so the
# options mirror programs.firefox. "beta" follows Zen's stable releases.
# Update checks and telemetry are already disabled by the module (mkDefault).
#
# setAsDefaultBrowser only fills xdg.mimeApps; home-manager writes
# mimeapps.list only when xdg.mimeApps.enable is set, hence the explicit enable.
#
# A homeManager class on a host-included aspect is inert in den; the config
# reaches the host's users through provides.to-users.
{ inputs, ... }:
{
  den.aspects.desktop-browser.provides.to-users.homeManager = {
    imports = [ inputs.zen-browser.homeModules.beta ];

    xdg.mimeApps.enable = true;

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true; # xdg.mimeApps -> zen-beta.desktop
      policies = {
        DisablePocket = true;
        DisableFirefoxStudies = true;
        DontCheckDefaultBrowser = true;
      };
    };
  };
}
