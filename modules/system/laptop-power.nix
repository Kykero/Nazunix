# Lid behaviour of a laptop. These are systemd's defaults, written out so the
# intent is visible: suspend on lid close on battery and on AC, keep running
# when docked (external screen plugged in). No hibernate: zram is the only swap.
{ ... }:
{
  den.aspects.laptop-power.nixos = {
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";
    };

    # only once `cat /sys/power/mem_sleep` lists `deep` (S3):
    # boot.kernelParams = [ "mem_sleep_default=deep" ];
  };
}
