# Review — handoff v2 « herdr unique + 2 comptes Claude Code » vs Nazunix

Confrontation du handoff v2 (2026-09-12) à l'état réel du dépôt au commit
`e6f0762`. Remplace les sections du handoff v1 (`herdr-claude-multi-account.md`)
devenues fausses : profils herdr/herd (n'existent pas), profils navigateur
obligatoires (optionnels), scripts `~/.local/bin` via `home.file` (remplacés
par un wrapper `claude` + `claude-a`/`claude-b`).

Légende : **OK** compatible tel quel · **ADAPTER** juste dans l'idée, faux
dans la forme pour ce dépôt · **DÉCISION** à trancher par l'opérateur ·
**BLOQUÉ** impossible avant une phase de la roadmap.

## 1. État du dépôt qui compte pour ce sujet

| Fait | Où | Conséquence pour le handoff |
|---|---|---|
| Aucun `nixConfig` dans `flake.nix`; les caches vivent dans l'aspect `nix-caches` et `check.yml` les lit dans la config évaluée | `flake.nix`, `modules/nix/caches.nix`, `.github/workflows/check.yml` | §4.1 `nixConfig` → ADAPTER |
| Règle roadmap : tout input `follows` nixpkgs, sauf `niri` (cache) | `docs/ROADMAP.md` §3 | `llm-agents` = deuxième exception, voir §2 |
| Home Manager = module NixOS via den (`den.schema.user.classes = ["homeManager"]`), pas de HM standalone | `modules/defaults.nix` | `extraSpecialArgs` du handoff n'existe pas ici, voir §3 |
| Les aspects home sont inclus depuis l'aspect utilisateur `nazuna` (`home-bash`, `home-btop`) | `modules/users/nazuna.nix` | point d'accroche naturel pour `home-claude` |
| L'aspect `nazuna` est aussi appliqué aux entités `-base` | `modules/hosts.nix` | claude-code + herdr arriveront sur la passerelle d'install, voir §3 |
| Le dépôt est public (pseudonyme Kykero); pas de dépôt dotfiles | `docs/ROADMAP.md` §1 | `~/dotfiles/claude-shared` → DÉCISION, voir §4 |
| Aucune machine installée : `hardware.nix` absent, phases 7-8 à venir | `docs/ROADMAP.md` §4-5 | tous les tests V1-V10 → BLOQUÉ jusqu'à la phase 7 |
| `check.yml` évalue les toplevels (drvPath) et ne construit que les trois apps phase 6 | `.github/workflows/check.yml` | ajouter herdr ne fait rien compiler en CI |
| `nh` pointe sur `/home/nazuna/Nazunix` | `modules/nh.nix` | chemins réels : `/home/nazuna/...`, pas `~/Projects/myapp` |

## 2. Paquets et cache (handoff §2 D4, §4.1)

**Vérifié dans llm-agents.nix (2026-09-12) :**
- `claude-code` = binaire natif préconstruit, wrappé avec `--argv0 claude`,
  `DISABLE_AUTOUPDATER=1`, `DISABLE_INSTALLATION_CHECKS=1` et
  `DISABLE_NON_ESSENTIAL_MODEL_CALLS=1` par défaut ; ajoute `bubblewrap` et
  `socat` au PATH sous Linux (sandbox). Le fichier prévient que les flags de
  télémétrie (`disableTelemetry`) « peuvent casser remote-control » : laisser
  ce paramètre à sa valeur par défaut.
- `herdr` = 0.9.0, **compilé depuis les sources** (`rustPlatform` + Zig 0.15
  pour libghostty-vt). Sans le cache numtide, c'est une compilation Rust sur le
  laptop 8 Go.
- README : le flake n'est testé que contre son `nixpkgs-unstable` épinglé ;
  « omit `follows` to receive pre-built binaries ».

**Verdict :**
- **ADAPTER** — pas de `nixConfig` : ajouter `https://cache.numtide.com` et sa
  clé dans `modules/nix/caches.nix`. Effets gratuits : `check.yml` importe le
  cache tout seul, et `den-bootstrap` le grave dans `/etc/nix/nix.conf` des
  entités `-base` dès l'install.
- **OK avec exception documentée** — `inputs.llm-agents.url =
  "github:numtide/llm-agents.nix";` **sans** `follows`, même raison que
  `niri` (herdr Rust + cache). Mettre à jour la phrase de la roadmap §3
  (« sauf `niri` » → « sauf `niri` et `llm-agents` »). Coût : un deuxième
  nixpkgs dans le lock, uniquement pour ces deux paquets.
- `lock.yml` à lancer manuellement après l'ajout de l'input (règle existante).
- herdr 0.9.0 ≥ 0.7.5 exigé par herd : OK.

## 3. Où accrocher le module (handoff §4.2)

Le `home/claude.nix` du handoff suppose un HM standalone avec
`extraSpecialArgs = { inherit inputs; }`. Ici :

- **ADAPTER** — un fichier `modules/homes/claude.nix` déclarant
  `den.aspects.home-claude`. `inputs` est disponible au niveau flake-parts et
  se capture par fermeture, exactement comme `modules/nix/settings.nix` capture
  `inputs.nixpkgs` dans un bloc `nixos` :

  ```nix
  { inputs, ... }:
  {
    den.aspects.home-claude = {
      homeManager = { pkgs, config, ... }:
        let llm = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
        in { home.packages = [ ... llm.herdr ]; xdg.configFile = ...; };
      nixos = { user, ... }: { users.users.${user.userName}.linger = true; };
    };
  }
  ```

  Le linger (handoff §4.8) vit dans le même aspect : la classe `nixos` reçoit
  `user` du contexte quand l'aspect est inclus depuis l'aspect utilisateur
  (même mécanique que le `shell` dans `nazuna.nix`).
- **DÉCISION** — inclusion depuis `den.aspects.nazuna.includes` (pattern
  existant) ou depuis `profile-full` seulement ?
  - Depuis `nazuna` : zéro mécanisme den nouveau, `user` disponible pour le
    linger, mais claude-code + herdr sont aussi installés sur `dazai-base` /
    `yamori-base`. Les deux viennent du cache, et la `-base` ne sert qu'à
    installer. **Recommandé.**
  - Depuis `profile-full` : garde la `-base` minimale, mais exige
    `den.batteries.host-aspects` sur `nazuna` (projection des classes
    `homeManager` du host vers l'utilisateur) et la classe `nixos` n'a plus
    `user` en scope : le linger devrait retourner dans `nazuna.nix`. La même
    question se posera pour `homes/mailspring.nix` (phase 10) : trancher une
    fois pour les deux.
- **OK** — wrapper `claude` en tête du PATH : `home.packages` atterrit dans
  `/etc/profiles/per-user/nazuna/bin`, devant `/run/current-system/sw/bin`.
  Règle à écrire dans le fichier : ne jamais ajouter `pkgs.claude-code`
  (nixpkgs) ni `llm.claude-code` ailleurs, ils masqueraient le wrapper.
- **OK** — `pkgs.writeShellApplication` : `set -euo pipefail`, `declare -A`,
  `compgen -G` dans un `if` : rien ne casse. `DISABLE_AUTOUPDATER=1` dans le
  wrapper est redondant avec le paquet numtide, inoffensif.
- `pkgs.jq` : requis par herd seulement ; à mettre avec herd (§5), pas ici.

## 4. Config partagée (handoff §2 D5, §4.3, §4.4)

- **OK** — `config.lib.file.mkOutOfStoreSymlink` fonctionne avec HM en module
  NixOS ; `config.xdg.configHome` et `config.home.homeDirectory` aussi.
- **DÉCISION** — cible du symlink. Le handoff propose
  `~/dotfiles/claude-shared` « versionné ». Il n'y a pas de dépôt dotfiles, et
  Nazunix est public : y mettre `skills/`, `CLAUDE.md` perso, `settings.json`
  (hooks, permissions) revient à les publier. Recommandation : cible
  `/home/nazuna/.config/claude-shared`, hors de tout dépôt public ; Nix ne
  déclare que les symlinks. Un dépôt privé séparé peut venir plus tard sans
  toucher au flake.
- **ADAPTER** — cycle de vie du dossier cible :
  - Les symlinks sont créés même si la cible n'existe pas (dangling), mais
    Claude Code ne pourra écrire `settings.json` qu'une fois le dossier
    parent présent. Prévoir soit `home.activation` qui fait `mkdir -p`, soit
    une étape manuelle documentée dans l'ordre d'implémentation (§6 étape 3).
  - `statusline.sh` doit être exécutable **sur la cible** ; Nix ne contrôle
    pas les droits d'un fichier hors store.
  - HM refuse d'écraser un fichier existant non géré : l'activation doit
    passer **avant** le premier `claude-a auth login`. Sur une machine
    fraîche c'est l'ordre naturel.
- **ADAPTER** — chemin dans `settings.json` : utiliser le chemin partagé
  absolu (`/home/nazuna/.config/claude-shared/statusline.sh`) plutôt que
  `~/.config/claude-a/...`, qui n'a de sens que par le symlink.
- **OK** — le `.gitignore` du handoff §7 vise un dépôt dotfiles ; rien à
  ajouter au `.gitignore` de Nazunix si `claude-shared` reste hors dépôt.

## 5. herdr, automations, herd (handoff §3, §4.5-4.8, §5)

- **OK** — `herdr agent start ... -- <args>` : la doc dit « Arguments after
  `--` are passed unchanged to that executable ». D3 tient.
- **[À VÉRIFIER] confirmé ouvert** — la doc ne dit pas comment herdr résout
  l'exécutable `claude` (PATH ou chemin fixe) ni quels flags il passe à la
  reprise : V1 et V4 restent des tests réels.
- **[À VÉRIFIER] confirmé ouvert** — mode serveur sans TUI : la doc parle d'un
  socket API et d'un serveur, mais aucune commande `herdr server`/headless n'est
  documentée. herdr-automations dit que la TUI n'a pas besoin de tourner, mais
  son scheduler parle au socket herdr : un serveur herdr doit exister. V10
  reste entier ; le service `systemd --user` est probablement à écrire.
- **Hors Nix, à assumer** — `herdr plugin install DnzzL/herdr-automations`
  télécharge des binaires Go dans l'état utilisateur ; `herd` s'installe par
  `./install.sh` dans `~/.local/bin` et pose son skill dans `~/.claude/skills`
  (jamais lu sous `CLAUDE_CONFIG_DIR`). Les deux sont impératifs. Acceptable au
  même titre que les credentials, à condition de le noter dans la roadmap.
  Empaqueter herd (quelques scripts bash) est faisable plus tard.
- **ADAPTER** — chemins des automations : `/home/nazuna/<dépôt>`, pas
  `~/Projects/myapp`. Si une automation touche Nazunix, l'identité git
  (noreply, clé de signature) est globale à l'utilisateur, donc indépendante
  du compte Claude : les règles de confidentialité tiennent. Ajouter à la
  liste `deny` du `settings.json` partagé tout `git push` non explicite vers
  Nazunix : CI est l'évaluateur, un push involontaire y déclenche un run.
- **Nouveau test V11** — `DISABLE_NON_ESSENTIAL_MODEL_CALLS=1` (défaut du
  paquet numtide) et Remote Control : vérifier que le paquet numtide n'active
  rien qui coupe Remote Control ; sinon surcharger le paquet
  (`llm.claude-code.override { ... }`) depuis `homes/claude.nix`.

## 6. Roadmap et ordre d'implémentation (handoff §6)

- Ce sujet n'est dans aucune phase 7-11. Proposer une **phase 12 « Agents »**
  (ou l'adosser à la phase 10 desktop). Chromium (D7) dépend de toute façon
  de la phase 10.
- **Faisable maintenant, CI comme juge** : input `llm-agents` (+ `lock.yml`),
  cache numtide dans `caches.nix`, `modules/homes/claude.nix` (wrapper,
  `claude-a`/`claude-b`, herdr, symlinks, linger), inclusion dans `nazuna`,
  mise à jour de la roadmap. Quatre commits, un par concern.
- **BLOQUÉ jusqu'à la phase 7 (yamori installé)** : tout le reste, V1 à V11.
  Le VM `vm-yamori` ne remplace pas : login OAuth, Remote Control et herdr en
  TUI y sont peu représentatifs.
- Étape 3 du handoff (« migrer skills, agents, commandes, CLAUDE.md et
  settings.json existants ») : il n'y a rien à migrer côté NixOS, la source
  est le poste Windows actuel. Copier vers `~/.config/claude-shared` en
  purgeant tout chemin Windows absolu et toute clé dans `env`.

## 7. Décisions à prendre avant de coder

1. Inclusion `home-claude` depuis `nazuna` (recommandé) ou `profile-full`.
2. Cible du partage : `/home/nazuna/.config/claude-shared` hors dépôt
   (recommandé) ou dépôt privé séparé.
3. Créer le dossier cible via `home.activation` (recommandé) ou à la main.
4. Phase 12 dédiée (recommandé) ou fusion dans la phase 10.
