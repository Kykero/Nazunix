# herdr: terminal multiplexer for coding agents. It runs the real `claude`
# and `codex` found on PATH and tells which panes are working or blocked
# (docs/herdr.md).
#
# Two options let other aspects hang things off herdr:
# - `herdr.settings` becomes config.toml. The file is owned by Nix: it is
#   copied, not linked, and rewritten on every switch, so a key or row a
#   plugin's setup step appends is lost at the next switch; it belongs in
#   `herdr.settings` instead. The theme is `terminal`, which draws herdr's
#   UI from the host terminal's ANSI palette, i.e. ghostty's Noctalia
#   colours (terminal.nix). A build-time `herdr config check` fails the
#   switch on a config herdr would reject.
# - `herdr.plugins` maps a plugin id to its folder in the store, registered
#   with `herdr plugin link` on every switch. Link runs no build steps, so
#   whatever a plugin needs comes from its own aspect. A store-linked plugin
#   dropped from the option is unlinked.
{ inputs, ... }:
{
  den.aspects.home-herdr.provides.to-users.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      herdr = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
      toml = pkgs.formats.toml { };
      cfg = config.herdr;
      generated = toml.generate "herdr-config.toml" cfg.settings;
      checked = pkgs.runCommand "herdr-config.toml" { nativeBuildInputs = [ herdr ]; } ''
        export HOME=$TMPDIR
        HERDR_CONFIG_PATH=${generated} herdr config check
        cp ${generated} $out
      '';
      herdrBin = "${herdr}/bin/herdr";
      jq = lib.getExe pkgs.jq;
    in
    {
      options.herdr = {
        settings = lib.mkOption {
          inherit (toml) type;
          default = { };
          description = "herdr's config.toml";
        };
        plugins = lib.mkOption {
          type = lib.types.attrsOf lib.types.path;
          default = { };
          description = "Plugin id to plugin folder, linked into herdr";
        };
      };

      config = {
        home.packages = [ herdr ];

        herdr.settings = {
          onboarding = false;
          theme.name = "terminal";
        };

        home.activation.herdrConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          f="${config.xdg.configHome}/herdr/config.toml"
          if [ -L "$f" ] || ! ${pkgs.diffutils}/bin/cmp -s ${checked} "$f"; then
            run mkdir -p "$(dirname "$f")"
            run rm -f "$f"
            run install -m 644 ${checked} "$f"
            run ${herdrBin} server reload-config >/dev/null 2>&1 || true
          fi
        '';

        home.activation.herdrPlugins = lib.hm.dag.entryAfter [ "herdrConfig" ] ''
          wanted=${lib.escapeShellArg (lib.concatStringsSep " " (lib.attrNames cfg.plugins))}
          for id in $(${herdrBin} plugin list --json 2>/dev/null \
            | ${jq} -r '.result.plugins[]? | select(.plugin_root | startswith("/nix/store/")) | .plugin_id'); do
            case " $wanted " in
              *" $id "*) ;;
              *) run ${herdrBin} plugin unlink "$id" >/dev/null ;;
            esac
          done
          ${lib.concatStrings (
            lib.mapAttrsToList (id: dir: ''
              if ! run ${herdrBin} plugin link ${dir} >/dev/null 2>&1; then
                run ${herdrBin} plugin unlink ${lib.escapeShellArg id} >/dev/null 2>&1 || true
                run ${herdrBin} plugin link ${dir} >/dev/null
              fi
            '') cfg.plugins
          )}
        '';
      };
    };
}
