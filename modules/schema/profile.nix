{ ... }:
{
  den.schema.host =
    { lib, ... }:
    {
      options.profile = lib.mkOption {
        type = lib.types.enum [ "base" "full" ];
        default = "full";
        description = "base: bootable minimum, cache-friendly; full: complete environment";
      };
    };
}
