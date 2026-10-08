# context7 MCP server (upstash): current library docs for Claude Code, the
# library IDs this repo queries are listed in CLAUDE.md. The server comes
# from nixpkgs instead of `npx -y @upstash/context7-mcp`.
#
# User-scope MCP servers live in ~/.claude.json, which Claude rewrites
# constantly (OAuth, caches, per-project state): activation sets the one
# key, the same thing `claude mcp add -s user` does, and keeps the rest.
{ ... }:
{
  den.aspects.home-claude-mcp-context7.provides.to-users.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      server = pkgs.writeText "context7.json" (
        builtins.toJSON {
          type = "stdio";
          command = lib.getExe pkgs.context7-mcp;
          args = [ ];
          env = { };
        }
      );
    in
    {
      home.activation.claudeMcpContext7 = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        f="${config.home.homeDirectory}/.claude.json"
        old='{}'
        [ -s "$f" ] && old=$(cat "$f")
        new=$(printf '%s' "$old" | ${lib.getExe pkgs.jq} --slurpfile s ${server} '.mcpServers.context7 = $s[0]')
        if [ "$new" != "$(printf '%s' "$old" | ${lib.getExe pkgs.jq} .)" ]; then
          tmp=$(mktemp)
          printf '%s\n' "$new" > "$tmp"
          run install -m 600 "$tmp" "$f"
          rm -f "$tmp"
        fi
      '';
    };
}
