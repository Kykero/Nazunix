# den-rebuild: day-2 helper for an already-installed machine. Pulls
# main and hands off to nh; refuses to run over local changes so a
# fast-forward merge is always safe.
{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.den-rebuild = pkgs.writeShellApplication {
        name = "den-rebuild";
        runtimeInputs = [
          pkgs.nh
          pkgs.git
        ];
        text = ''
          # NH_FLAKE comes from programs.nh.flake (modules/nh.nix); NH_OS_FLAKE
          # is nh's own optional per-command override. Read the path from the
          # environment instead of hardcoding it a second time.
          cd "''${NH_OS_FLAKE:-''${NH_FLAKE:?set by programs.nh}}" || exit 1

          if [ -n "$(git status --porcelain)" ]; then
            echo "error: local changes present -- commit or stash first" >&2
            exit 1
          fi

          git fetch origin
          git merge --ff-only origin/main
          exec nh os switch "$@"
        '';
      };
    };
}
