# OmO as herdr-projects' coordinator (herdr-projects.nix, docs/omo.md).
#
# herdr starts an agent by kind, and the kind is also the executable:
# `herdr agent start --kind pi` runs `pi`. omo is a fork of pi that takes
# the same launch flags (--model, --thinking, --session), so a `pi` on PATH
# that execs omo lets the `pi` profile, the coordinator's default, start
# omo. Nothing else installs a `pi`.
#
# herdr-projects lists the `pi` profile only when pi looks signed in, which
# it checks in $PI_CODING_AGENT_DIR/auth.json. omo reads that variable last
# (after OMO_ and SENPI_CODING_AGENT_DIR), and it points at omo's own
# default, ~/.omo/agent, so omo itself sees no change.
#
# The standing rule below is global, for every project: Claude Code and
# omo both read ~/.claude/rules/, and the rule only applies to the agent
# acting as a herdr-projects coordinator.
{ ... }:
{
  den.aspects.home-omo-pi.provides.to-users.homeManager =
    { config, pkgs, ... }:
    {
      home.sessionVariables.PI_CODING_AGENT_DIR = "${config.home.homeDirectory}/.omo/agent";

      home.packages = [
        (pkgs.writeShellScriptBin "pi" ''
          exec omo "$@"
        '')
      ];

      home.file.".claude/rules/herdr-projects-coordinator.md".text = ''
        # herdr-projects coordinator

        These rules apply only when you are the coordinator of a
        herdr-projects project (your working directory is
        ~/.herdr-projects/<project> and its AGENTS.md says you coordinate).
        Workers and other sessions ignore them.

        - When a thread has finished (its progress says Done and you have
          summarized its report to the user), resolve it with
          `herdr-projects thread resolve <project> <id>` so its worktree,
          tab and workspace close. Its report, library and unmerged branch
          are kept. Do not resolve a thread the user asked to keep open, or
          one still waiting on the user.
        - When the user wants to continue a resolved task, start a new
          thread from it (`thread start ... --from-task`), or bring back a
          thread whose pane is gone with `thread restart`.
      '';
    };
}
