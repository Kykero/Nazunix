{ inputs, den, lib, ... }:
{
  # autologin inside VMs only
  den.aspects.dazai.includes = [ (den.batteries.vm-autologin "nazuna") ];
  den.aspects.yamori.includes = [ (den.batteries.vm-autologin "nazuna") ];

  perSystem =
    { pkgs, ... }:
    {
      packages = lib.mapAttrs' (
        name: cfg:
        lib.nameValuePair "vm-${name}" (
          pkgs.writeShellApplication {
            name = "vm-${name}";
            text = ''
              ${cfg.config.system.build.vm}/bin/run-${cfg.config.networking.hostName}-vm "$@"
            '';
          }
        )
      ) inputs.self.nixosConfigurations;
    };
}
