# The full gaming bundle. A host that only wants part of it includes the
# sub-aspect directly (den.aspects.gaming._.steam).
{ den, ... }:
{
  den.aspects.gaming.includes = with den.aspects.gaming._; [
    steam
    proton-ge
    protontricks
    prism
    wine
  ];
}
