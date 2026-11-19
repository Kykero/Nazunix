# rea (morluto): reverse-engineering tools for agents, from native binaries
# to JavaScript/Electron apps and websites. One aspect brings what
# `rea setup` would: the `rea` command, its MCP server registered in Claude
# Code, the matching reverse-engineer-anything skill, and a native analysis
# engine.
#
# Not in nixpkgs. The npm release bundles its dependencies, so the pinned
# tarball runs straight from the store with nixpkgs' Node, nothing is
# installed at runtime. Its optional frida dependency is not bundled and is
# left out.
#
# The engine is Ghidra with the JDK its release declares (12.2 wants 25):
# rea only reads GHIDRA_INSTALL_DIR and JAVA_HOME, so Ghidra is referenced
# by path and its GUI never lands in the profile. Both can be overridden
# from the environment.
#
# The MCP entry is set in ~/.claude.json like context7
# (claude-mcp-context7.nix).
{ ... }:
{
  den.aspects.home-rea.provides.to-users.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      version = "6.9.0";
      src = pkgs.runCommand "rea-agents-${version}" {
        tarball = pkgs.fetchurl {
          url = "https://registry.npmjs.org/rea-agents/-/rea-agents-${version}.tgz";
          hash = "sha512-KqDn1UR5BMqHoQ3MGAnPuWiSKwgdFaz1L/uUNgrKt+1W8kPtgYP8AWEOXIF1lDIOBVyPuYIIst2iamo1Wf3r8g==";
        };
      } "mkdir $out && tar -xzf $tarball -C $out --strip-components=1";
      rea = pkgs.writeShellScriptBin "rea" ''
        export GHIDRA_INSTALL_DIR="''${GHIDRA_INSTALL_DIR:-${pkgs.ghidra}/lib/ghidra}"
        export JAVA_HOME="''${JAVA_HOME:-${pkgs.jdk25.home}}"
        exec ${lib.getExe pkgs.nodejs} ${src}/scripts/rea.mjs "$@"
      '';
      server = pkgs.writeText "rea.json" (
        builtins.toJSON {
          type = "stdio";
          command = lib.getExe rea;
          args = [ "mcp" ];
          env = { };
        }
      );
    in
    {
      home.packages = [ rea ];

      home.file.".claude/skills/reverse-engineer-anything".source =
        "${src}/skills/reverse-engineer-anything";

      home.activation.claudeMcpRea = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        f="${config.home.homeDirectory}/.claude.json"
        old='{}'
        [ -s "$f" ] && old=$(cat "$f")
        new=$(printf '%s' "$old" | ${lib.getExe pkgs.jq} --slurpfile s ${server} '.mcpServers.rea = $s[0]')
        if [ "$new" != "$(printf '%s' "$old" | ${lib.getExe pkgs.jq} .)" ]; then
          tmp=$(mktemp)
          printf '%s\n' "$new" > "$tmp"
          run install -m 600 "$tmp" "$f"
          rm -f "$tmp"
        fi
      '';
    };
}
