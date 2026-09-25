# serena MCP server (oraios): LSP-backed symbol lookup, references and
# semantic edits for Claude Code. Not in nixpkgs; uvx builds it from the
# pinned tag on first start and caches it. uv is pointed at nixpkgs' Python
# and forbidden to download its own: uv's standalone builds do not run on
# NixOS. --project-from-cwd activates the repo Claude is started in, and
# the browser dashboard stays closed (it is still served on localhost).
#
# The entry is set in ~/.claude.json like context7 (claude-mcp-context7.nix).
{ ... }:
{
  den.aspects.home-claude-mcp-serena.provides.to-users.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      version = "1.7.0";
      serena = pkgs.writeShellScript "serena-mcp" ''
        export UV_PYTHON=${lib.getExe pkgs.python3}
        export UV_PYTHON_DOWNLOADS=never
        exec ${lib.getExe' pkgs.uv "uvx"} --from git+https://github.com/oraios/serena@v${version} \
          serena start-mcp-server --context claude-code --project-from-cwd \
          --open-web-dashboard False "$@"
      '';
      server = pkgs.writeText "serena.json" (
        builtins.toJSON {
          type = "stdio";
          command = "${serena}";
          args = [ ];
          env = { };
        }
      );
    in
    {
      home.activation.claudeMcpSerena = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        f="${config.home.homeDirectory}/.claude.json"
        old='{}'
        [ -s "$f" ] && old=$(cat "$f")
        new=$(printf '%s' "$old" | ${lib.getExe pkgs.jq} --slurpfile s ${server} '.mcpServers.serena = $s[0]')
        if [ "$new" != "$(printf '%s' "$old" | ${lib.getExe pkgs.jq} .)" ]; then
          tmp=$(mktemp)
          printf '%s\n' "$new" > "$tmp"
          run install -m 600 "$tmp" "$f"
          rm -f "$tmp"
        fi
      '';
    };
}
