# Python 3 provider (:checkhealth provider.python): the nvim wrapper gets
# its own python3 with pynvim, so plugins using the remote-plugin API work
# without any system Python.
{ ... }:
{
  vimzuna.python = {

    vim = {
      withPython3 = true;
      python3Packages = [ "pynvim" ];
    };

  };
}
