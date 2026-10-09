# EasyEffects, PipeWire effects on inputs and outputs (EQ, compressor, gate,
# RNNoise noise suppression on the mic). Run through home-manager's service,
# not a bare package, so presets keep applying from login without the window
# open.
{ ... }:
{
  den.aspects.desktop-easyeffects.provides.to-users.homeManager =
    {
      services.easyeffects.enable = true;
    };
}
