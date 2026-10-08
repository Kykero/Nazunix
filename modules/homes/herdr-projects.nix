# herdr-projects: a herdr plugin where one coordinator agent hands the work
# out to worker threads, each an agent in its own pane and git worktree
# (docs/herdr.md). Here the coordinator is OmO (omo-pi.nix).
#
# Everything `herdr-projects configure` would do is done here instead,
# since herdr's config.toml is Nix-owned and a configure edit would not
# survive a switch:
# - the plugin is linked from a store folder: the release source (manifest,
#   skill, scripts) with the release's static musl binary placed where the
#   manifest expects it, target/release/. Its `startup` hook starts the
#   ticker with the server. `herdr-projects update` cannot replace a store
#   binary: bump `version` and the hashes instead (SHA256SUMS of the
#   release, and the source).
# - the popup key, the tab-bar count and the sidebar rows go into
#   herdr.settings; the claude/codex rows get the `$hp_sub` line after
#   clauth's rows.
# - its progress hooks are merged into ~/.claude/settings.json and
#   ~/.codex/hooks.json on every switch, replacing earlier herdr-projects
#   entries (claude-plugins.nix for why those files are merged).
# - the autoproject skill is linked for Claude Code and ~/.agents.
# - ~/.config/herdr-projects/config.toml gets the default profiles merged
#   in; the rest of the file (safety, profiles added in the popup) is left
#   to herdr-projects.
#
# The ZERO WIDTH SPACE (U+200B) and BRAILLE BLANK (U+2800) in the sidebar
# rules are herdr-projects' markers for project agents and Spaces; keep them.
{ ... }:
{
  den.aspects.home-herdr-projects.provides.to-users.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      version = "0.2.34";
      targets = {
        x86_64-linux = {
          triple = "x86_64-unknown-linux-musl";
          hash = "sha256-+bgJO8x88vjfN4CsyYS7Nxye8oq86HrEP6+1hSEHslg=";
        };
        aarch64-linux = {
          triple = "aarch64-unknown-linux-musl";
          hash = "sha256-CqGFYv8f43eyt7xPM5GZ0Y78dZcsh/ShTrjBXpyqTPw=";
        };
      };
      target = targets.${pkgs.stdenv.hostPlatform.system};
      src = pkgs.fetchFromGitHub {
        owner = "eliasstravik";
        repo = "herdr-projects";
        tag = "v${version}";
        hash = "sha256-3Pmg0yDPFRY8fWI3Qc/0oMxnbFTBTHM48C38v63wFP4=";
      };
      binary = pkgs.fetchurl {
        url = "https://github.com/eliasstravik/herdr-projects/releases/download/v${version}/herdr-projects-${target.triple}";
        inherit (target) hash;
      };
      plugin = pkgs.runCommand "herdr-projects-plugin-${version}" { } ''
        cp -r ${src} $out
        chmod -R u+w $out
        install -Dm755 ${binary} $out/target/release/herdr-projects
      '';
      exe = "${plugin}/target/release/herdr-projects";
      root = "${config.home.homeDirectory}/.herdr-projects";
      hook = agent: "${exe} --root ${root} hook --agent ${agent} 2>/dev/null || true";
      subRow = [
        {
          token = "$hp_sub";
          dim = true;
        }
      ];

      hooksFor =
        agent:
        pkgs.writeText "herdr-projects-hooks-${agent}.json" (
          builtins.toJSON (
            lib.genAttrs [ "SessionStart" "UserPromptSubmit" "PostToolUse" ] (_: [
              {
                matcher = "*";
                hooks = [
                  {
                    type = "command";
                    command = hook agent;
                    timeout = 10;
                  }
                ];
              }
            ])
          )
        );
      jq = lib.getExe pkgs.jq;
      # merge one agent's hooks into its JSON file, dropping any earlier
      # herdr-projects entry (an older store path or the hand-installed one)
      mergeHooks = file: agent: ''
        f="${file}"
        if [ -d "$(dirname "$f")" ]; then
          old='{}'
          [ -s "$f" ] && old=$(cat "$f")
          new=$(printf '%s' "$old" | ${jq} --slurpfile add ${hooksFor agent} '
            .hooks = ((.hooks // {}) | with_entries(.value |= map(
              select(any(.hooks[]?; (.command // "") | test("herdr-projects.* hook --agent")) | not)
            )))
            | reduce ($add[0] | to_entries[]) as $e (.; .hooks[$e.key] = ((.hooks[$e.key] // []) + $e.value))')
          if [ "$new" != "$(printf '%s' "$old" | ${jq} .)" ]; then
            tmp=$(mktemp)
            printf '%s\n' "$new" > "$tmp"
            run install -m 644 "$tmp" "$f"
            rm -f "$tmp"
          fi
        fi
      '';

      defaults = (pkgs.formats.toml { }).generate "herdr-projects-defaults.toml" {
        defaults = {
          coordinator_profile = "pi";
          thread_profile = "claude";
        };
      };
      python = pkgs.python3.withPackages (ps: [ ps.tomli-w ]);
      mergeToml = pkgs.writeText "merge-toml.py" ''
        import sys, tomllib, tomli_w
        from pathlib import Path

        def merge(base, add):
            for k, v in add.items():
                if isinstance(v, dict) and isinstance(base.get(k), dict):
                    merge(base[k], v)
                else:
                    base[k] = v
            return base

        target, fragment = Path(sys.argv[1]), Path(sys.argv[2])
        base = tomllib.loads(target.read_text()) if target.exists() else {}
        new = tomli_w.dumps(merge(dict(base), tomllib.loads(fragment.read_text())))
        if not target.exists() or target.read_text() != new:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(new)
      '';
    in
    {
      home.packages = [
        (pkgs.runCommand "herdr-projects-${version}" { } ''
          mkdir -p $out/bin
          ln -s ${exe} $out/bin/herdr-projects
        '')
      ];

      herdr.plugins."herdr-projects" = "${plugin}";
      herdr.settings = {
        keys.command = [
          {
            key = "prefix+shift+j";
            type = "plugin_action";
            command = "herdr-projects.open-popup";
            description = "Projects";
          }
        ];
        ui = {
          tab_bar_right = [
            {
              type = "command";
              command = "${exe} --root ${root} needs-you --line";
              interval_seconds = 15;
              timeout_seconds = 5;
            }
          ];
          sidebar.agents.rows = [
            [
              "state_icon"
              {
                token = "agent";
                bold = false;
                dim = false;
                rules = [
                  {
                    contains = "​";
                    bold = true;
                  }
                ];
              }
              "state_text"
            ]
            subRow
          ];
          sidebar.agents.rows_by_agent = {
            claude = lib.mkAfter [ subRow ];
            codex = lib.mkAfter [ subRow ];
          };
          sidebar.spaces.rows = [
            [
              "state_icon"
              {
                token = "workspace";
                rules = [
                  {
                    contains = "⠀";
                    bold = true;
                  }
                ];
              }
              {
                token = "branch";
                dim = true;
              }
              "git_status"
            ]
          ];
        };
      };

      home.file.".claude/skills/autoproject" = {
        source = "${src}/skill/autoproject";
        force = true;
      };
      home.file.".agents/skills/autoproject" = {
        source = "${src}/skill/autoproject";
        force = true;
      };

      home.activation.herdrProjects = lib.hm.dag.entryAfter [ "herdrIntegrations" "claudePlugins" "claudeRtkHook" ] ''
        ${mergeHooks "${config.home.homeDirectory}/.claude/settings.json" "claude"}
        ${mergeHooks "${config.home.homeDirectory}/.codex/hooks.json" "codex"}
        run ${lib.getExe python} ${mergeToml} "${config.xdg.configHome}/herdr-projects/config.toml" ${defaults}
      '';
    };
}
