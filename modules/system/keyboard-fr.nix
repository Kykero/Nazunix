# AZERTY on the console: password prompts on the TTY, the -base gateway.
# niri and the greeter carry their own xkb layout setting.
{ ... }:
{
  den.aspects.keyboard-fr.nixos = {
    console.keyMap = "fr";
  };
}
