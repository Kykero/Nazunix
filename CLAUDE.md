# Nazunix

Declarative NixOS configuration (flake) for a small personal fleet: `yamori`
(desktop, builder) and `dazai` (laptop), each with a `-base` install-gateway
entity sharing the same hardware aspect. Single user: `nazuna`. Built on
flake-parts + import-tree + the **den** framework.

## Ground rules

- **No local Nix.** Development happens on Windows; GitHub Actions (`check.yml`)
  is the only evaluator. Never claim something evaluates — push and read the run.
- **Privacy is a hard constraint.** No emails, disk serials (`/dev/nvme0n1`, never
  `by-id`), MACs, IPs, ISP hostnames, or absolute Windows paths in the repo or
  commit metadata. Commit author must be the GitHub noreply address. No
  `nixos-facter`. Scan every diff before committing.
- **Dendritic style.** One concern per file, every file a flake-parts module
  auto-discovered by import-tree. Compose via den aspects and `includes`, never
  `imports` chains or hostname conditionals. Prefer adding a file over growing one.
- **`modules/hosts.nix` is the sole registry** of machine declarations; per-machine
  implementation lives in `modules/hosts/<machine>/`.
- **`default.nix` is forbidden** as a module filename.
- **Commit discipline:** one logical change per commit, push, wait for `check`,
  read the verdict. `lock.yml` is run manually, only when a flake input changes.
- Code, comments, commit messages, and repo docs in English.

## Documentation (Context7 MCP)

Query docs with `query-docs` using these library IDs directly:

- `/denful/den` — den framework (aspects, hosts, schema, batteries, policies)
- `/nixos/nix` — Nix (language, flakes, CLI)
- `/websites/wiki_nixos_wiki` — NixOS Wiki
- `/nixos/nixpkgs` — Nixpkgs (packages, lib, modules)
- `/websites/nixos_manual_nixos_unstable` — NixOS manual (unstable)
- `/websites/nix_dev` — nix.dev (official tutorials and references)
