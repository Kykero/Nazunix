{ ... }:
{
  den.aspects.home-bash.homeManager = {
    programs.bash = {
      enable = true;
      enableCompletion = true;

      historyControl = [
        "ignoredups"
        "ignorespace"
      ];
      historySize = 10000;

      shellAliases = {
        ll = "ls -alh";
        la = "ls -A";
        ".." = "cd ..";
      };
    };
  };
}
