# den-rebuild: day-2 helper for an already-installed machine. Pulls
# main and hands off to nh; refuses to run over local changes so a
# fast-forward merge is always safe. The caches declared in the flake
# are passed to the build, so a cache added in the new config (numtide
# for llm-agents) already serves the switch that activates it.
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
          # the running /etc/nix/nix.conf only knows the caches of the current
          # generation; read the new ones from the flake. @wheel is trusted
          # (nix/settings.nix), so these --option flags are honoured.
          host=$(cat /proc/sys/kernel/hostname)
          subs=$(nix eval --raw ".#nixosConfigurations.$host.config.nix.settings.substituters" \
            --apply 'builtins.concatStringsSep " "')
          keys=$(nix eval --raw ".#nixosConfigurations.$host.config.nix.settings.trusted-public-keys" \
            --apply 'builtins.concatStringsSep " "')

          exec nh os switch "$@" -- \
            --option extra-substituters "$subs" \
            --option extra-trusted-public-keys "$keys"
        '';
      };
    };
}
