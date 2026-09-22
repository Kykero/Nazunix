# Handoff — Herdr + Claude Code multi-comptes sur NixOS

## 1. Objectif

Mettre en place sur une machine NixOS un environnement d'orchestration basé sur **Herdr/Herd**, en conservant un workflow principalement terminal.

L'utilisateur possède **2 comptes Claude distincts**, chacun avec ses propres credentials/subscription.

Le système doit permettre :

* d'utiliser simultanément les deux comptes Claude ;
* de lancer plusieurs agents Claude Code en parallèle ;
* d'isoler complètement les credentials/configurations des deux comptes ;
* d'isoler également les profils navigateur et leurs cookies ;
* de ne pas devoir refaire le login Claude à chaque changement de compte ;
* de pouvoir scheduler des prompts/agents ;
* de conserver les sessions dans le terminal ;
* de pouvoir éventuellement reprendre les sessions via Claude Remote Control depuis le téléphone ;
* d'être compatible avec NixOS/Home Manager ;
* de garder la configuration reproductible autant que possible.

---

# 2. Architecture souhaitée

Architecture cible :

```text
                               NixOS
                                 │
                              HERDR
                                 │
             ┌───────────────────┴───────────────────┐
             │                                       │
       PROFILE CLAUDE A                         PROFILE CLAUDE B
             │                                       │
       Claude Account A                         Claude Account B
             │                                       │
       CLAUDE_CONFIG_DIR                         CLAUDE_CONFIG_DIR
       ~/.config/claude-a                        ~/.config/claude-b
             │                                       │
       credentials A                            credentials B
             │                                       │
       Browser Profile A                        Browser Profile B
             │                                       │
       cookies/session A                        cookies/session B
             │                                       │
       ┌─────┴─────┐                            ┌─────┴─────┐
       │           │                            │           │
    Agent A1    Agent A2                     Agent B1    Agent B2
```

L'idée fondamentale est que **le compte A et le compte B ne doivent jamais partager leur environnement d'authentification**.

---

# 3. Isolation Claude Code

Utiliser `CLAUDE_CONFIG_DIR` pour séparer les configurations.

Exemple conceptuel :

```bash
export CLAUDE_CONFIG_DIR="$HOME/.config/claude-a"
```

et :

```bash
export CLAUDE_CONFIG_DIR="$HOME/.config/claude-b"
```

Les deux environnements doivent avoir leur propre :

* credentials ;
* historique ;
* configuration ;
* plugins si nécessaire ;
* état Claude Code.

Ne jamais mettre les credentials dans le repository Git ou dans le flake Nix.

Les secrets doivent rester dans les répertoires utilisateur appropriés.

---

# 4. Profils Herdr

Configurer Herdr pour avoir deux profiles logiques :

```text
account-a
account-b
```

Exemple conceptuel :

```bash
herd --profile account-a
```

et :

```bash
herd --profile account-b
```

Chaque profile doit pointer vers son environnement Claude Code correspondant.

Objectif :

```text
Herdr profile account-a
    ↓
CLAUDE_CONFIG_DIR=~/.config/claude-a
    ↓
Claude Account A
```

et :

```text
Herdr profile account-b
    ↓
CLAUDE_CONFIG_DIR=~/.config/claude-b
    ↓
Claude Account B
```

Vérifier précisément le comportement réel de la version de Herdr utilisée avant de finaliser la configuration.

---

# 5. Navigateurs isolés

Créer deux profils navigateur complètement séparés.

Chromium/Chrome est préférable si les fonctionnalités Claude in Chrome sont nécessaires.

Exemple :

```text
~/.config/chromium-claude-a/
~/.config/chromium-claude-b/
```

Le profil A doit contenir :

```text
Cookies A
Sessions A
Claude.ai login A
Claude in Chrome state A
```

Le profil B :

```text
Cookies B
Sessions B
Claude.ai login B
Claude in Chrome state B
```

Ne jamais utiliser un même profil Chromium pour les deux comptes.

Exemple de lancement :

```bash
chromium \
  --user-data-dir="$HOME/.config/chromium-claude-a"
```

et :

```bash
chromium \
  --user-data-dir="$HOME/.config/chromium-claude-b"
```

Les deux profils doivent pouvoir rester ouverts simultanément.

---

# 6. Login initial

Effectuer une seule fois le login de chaque compte.

### Compte A

1. Lancer le profil navigateur A.
2. Se connecter au compte Claude A.
3. Initialiser Claude Code avec le `CLAUDE_CONFIG_DIR` A.
4. Vérifier que les credentials sont persistants.
5. Tester plusieurs lancements de Claude Code.

### Compte B

Même procédure avec les environnements B.

Après cette initialisation, le workflow normal doit être :

```text
lancer profile A → compte A immédiatement disponible
lancer profile B → compte B immédiatement disponible
```

Il ne faut pas demander de refaire le login simplement parce que l'utilisateur passe d'un compte à l'autre.

Si Claude/Anthropic invalide réellement une session ou demande périodiquement une nouvelle authentification, cela reste évidemment possible.

---

# 7. Commandes ergonomiques

Créer des commandes simples :

```bash
claude-a
```

et :

```bash
claude-b
```

Elles doivent automatiquement sélectionner le bon environnement.

Conceptuellement :

```bash
#!/usr/bin/env bash

export CLAUDE_CONFIG_DIR="$HOME/.config/claude-a"

exec claude "$@"
```

et :

```bash
#!/usr/bin/env bash

export CLAUDE_CONFIG_DIR="$HOME/.config/claude-b"

exec claude "$@"
```

Faire la même chose pour les profiles Herdr si nécessaire.

L'objectif est de ne jamais devoir manipuler manuellement `CLAUDE_CONFIG_DIR`.

---

# 8. Orchestration

Herdr doit être utilisé comme couche d'orchestration, pas comme remplacement de Claude Code.

Claude Code reste l'agent.

Herdr gère notamment :

* lancement des sessions ;
* isolation ;
* gestion des agents ;
* profils ;
* panes/sessions terminal ;
* orchestration ;
* éventuellement scheduling.

Architecture :

```text
Utilisateur
    │
    ▼
  Herdr
    │
    ├── Claude A / agent 1
    ├── Claude A / agent 2
    ├── Claude B / agent 1
    └── Claude B / agent 2
```

Chaque agent doit être identifiable par :

* compte Claude utilisé ;
* projet ;
* branche/worktree ;
* rôle ;
* session.

---

# 9. Git worktrees

Pour les tâches parallèles, privilégier les worktrees Git afin d'éviter que plusieurs agents modifient simultanément le même working tree.

Exemple :

```text
project/
├── main
├── .worktrees/
│   ├── agent-a1/
│   ├── agent-a2/
│   ├── agent-b1/
│   └── agent-b2/
```

Chaque agent reçoit son propre worktree.

Exemple :

```text
Agent A1
→ account A
→ worktree agent-a1
→ tâche backend

Agent B1
→ account B
→ worktree agent-b1
→ tâche frontend
```

Cela doit réduire fortement les conflits entre agents.

---

# 10. Scheduling

Installer/configurer le système d'automatisation compatible Herdr, notamment `herdr-automations` si celui-ci reste compatible avec la version utilisée.

Objectif :

```text
09:00
 ↓
Herdr
 ↓
Claude Account A
 ↓
Analyse les issues
 ↓
Crée une branche/worktree
 ↓
Implémente les tâches simples
```

Exemple conceptuel :

```yaml
automations:
  - name: daily-review
    cron: "0 9 * * 1-5"
    repo: ~/Projects/myproject
    agent: claude
    prompt: |
      Analyse les issues ouvertes.
      Identifie les tâches simples.
      Implémente uniquement celles qui sont suffisamment
      spécifiées.
      Crée un commit propre.
      Ne merge jamais directement dans main.
```

Prévoir des automatisations différentes selon le compte si nécessaire.

Par exemple :

```text
Account A
→ développement principal

Account B
→ review / tests / documentation
```

---

# 11. Priorité des comptes

Ne pas supposer automatiquement qu'un compte doit être utilisé pour toutes les tâches.

Prévoir la possibilité de choisir explicitement :

```text
account-a
account-b
```

ou :

```text
premium-a
premium-b
```

dans la configuration d'une automation.

À terme, un routeur pourrait décider :

```text
tâche complexe
→ Claude A

review
→ Claude B

tests simples
→ Claude B

architecture
→ Claude A
```

Mais cette logique doit être ajoutée seulement après avoir validé le fonctionnement de base.

---

# 12. NixOS / Home Manager

L'installation doit être compatible avec le système NixOS existant.

Privilégier Home Manager pour :

* scripts `claude-a` / `claude-b` ;
* variables d'environnement ;
* aliases ;
* packages utilisateur ;
* fichiers de configuration ;
* éventuels services user systemd.

Les credentials et cookies ne doivent PAS être déclarés dans Nix.

Le flake doit seulement gérer l'infrastructure.

Exemple conceptuel :

```nix
home.packages = [
  herdr
  chromium
];

home.file = {
  ".local/bin/claude-a".source = ./scripts/claude-a;
  ".local/bin/claude-b".source = ./scripts/claude-b;
};
```

Adapter à la méthode d'installation réellement disponible pour Herdr.

---

# 13. Systemd user

Si le scheduler nécessite un processus persistant, privilégier un service `systemd --user`.

Objectif :

```text
NixOS boot
   ↓
systemd user
   ↓
Herdr automation daemon
   ↓
scheduler
```

Ainsi les automatisations ne dépendent pas de l'ouverture manuelle d'un terminal.

Vérifier également le comportement après :

* reboot ;
* logout ;
* veille ;
* perte réseau ;
* reconnexion réseau.

---

# 14. Terminal

Le terminal doit rester l'interface principale.

Ne pas construire une UI web obligatoire.

L'utilisateur doit pouvoir faire :

```bash
herd
```

et retrouver ses agents.

Le système doit fonctionner avec :

* tmux ;
* terminal classique ;
* SSH ;
* éventuellement terminal depuis téléphone.

La priorité est de conserver la visibilité et le contrôle directement depuis le terminal.

---

# 15. Claude Remote Control

Prévoir la compatibilité avec Claude Code Remote Control.

Objectif :

```text
PC NixOS
   │
   ├── Herdr
   │    ├── Claude A
   │    └── Claude B
   │
   ▼
Claude Remote Control
   │
   ▼
Téléphone
```

L'utilisateur doit pouvoir reprendre une session Claude Code depuis l'application Claude lorsque cette fonctionnalité est disponible pour la session.

Important :

Herdr ne doit pas remplacer le mécanisme Remote Control de Claude Code.

Il doit simplement maintenir/lancer les sessions Claude Code concernées.

---

# 16. Sécurité

Ne jamais :

* mettre les credentials Claude dans Git ;
* mettre les cookies navigateur dans Git ;
* mettre des tokens dans le flake ;
* partager accidentellement `.config/claude-a` avec le compte B ;
* partager le profil Chromium A avec B.

Ajouter les répertoires sensibles au `.gitignore` si nécessaire.

Exemple :

```gitignore
.config/
credentials*
*.cookie
```

Adapter au repository réel.

---

# 17. Tests à effectuer

Avant de considérer le setup terminé :

### Test 1 — comptes

```text
Claude A → répond comme compte A
Claude B → répond comme compte B
```

### Test 2 — persistance

Fermer Claude Code puis le relancer.

Résultat attendu :

```text
pas de nouveau login
```

### Test 3 — navigateur

Fermer les deux navigateurs puis :

```text
ouvrir Browser A → compte A
ouvrir Browser B → compte B
```

### Test 4 — simultanéité

Lancer :

```text
Claude A
Claude B
```

simultanément.

Aucun credential ne doit être utilisé par erreur.

### Test 5 — agents multiples

Lancer au moins :

```text
A1
A2
B1
B2
```

simultanément.

### Test 6 — worktrees

Vérifier que les agents travaillent dans des worktrees différents.

### Test 7 — scheduler

Créer une automation de test qui s'exécute dans quelques minutes.

Vérifier :

* lancement ;
* bon compte ;
* bon repository ;
* bon worktree ;
* prompt correct ;
* logs ;
* résultat.

### Test 8 — reboot

Redémarrer NixOS.

Vérifier que le scheduler et les sessions nécessaires reviennent correctement.

---

# 18. Ordre d'implémentation recommandé

Ne pas essayer de tout construire simultanément.

### Phase 1

Installer Herdr et vérifier son fonctionnement basique.

### Phase 2

Créer :

```text
Claude Account A
Claude Account B
```

avec deux `CLAUDE_CONFIG_DIR`.

### Phase 3

Créer les deux profils navigateur.

### Phase 4

Valider les deux logins et leur persistance.

### Phase 5

Lancer plusieurs Claude Code simultanément.

### Phase 6

Ajouter les Git worktrees.

### Phase 7

Ajouter le scheduler.

### Phase 8

Ajouter les services systemd user si nécessaire.

### Phase 9

Tester Remote Control.

### Phase 10

Ajouter éventuellement une logique de routage automatique des tâches entre les deux comptes.

---

# 19. Résultat final attendu

Le workflow quotidien doit être extrêmement simple.

Par exemple :

```bash
herd
```

Puis :

```text
┌───────────────────────────────────────────────────────────┐
│ HERDR                                                     │
├───────────────────────────────────────────────────────────┤
│                                                           │
│ Account A                                                 │
│ ├── backend-agent      running                            │
│ └── architecture-agent running                            │
│                                                           │
│ Account B                                                 │
│ ├── frontend-agent     running                            │
│ └── reviewer-agent     running                            │
│                                                           │
│ Scheduled                                                 │
│ ├── daily-review       09:00                              │
│ ├── tests              14:00                              │
│ └── nightly-maintenance 02:00                             │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

L'utilisateur doit pouvoir changer de compte sans refaire de login :

```text
Account A
→ credentials A
→ browser A
→ cookies A

Account B
→ credentials B
→ browser B
→ cookies B
```

Le tout doit fonctionner sur NixOS et rester principalement pilotable depuis le terminal.

---

# 20. Important — validation avant automatisation

Avant de développer des scripts complexes, vérifier la documentation et le comportement actuel des versions installées de :

* Herdr/Herd ;
* Claude Code ;
* `CLAUDE_CONFIG_DIR` ;
* Claude Remote Control ;
* Claude in Chrome ;
* `herdr-automations`.

Ne pas supposer qu'une fonctionnalité existe simplement parce qu'elle est mentionnée dans un ancien exemple.

Le setup doit être adapté aux versions réellement disponibles sur NixOS au moment de l'installation.

## Priorité absolue

**Faire fonctionner correctement les deux comptes Claude isolés avant de construire l'orchestration avancée.**

Si l'isolation des credentials fonctionne :

```text
A ↔ credentials A ↔ browser A
B ↔ credentials B ↔ browser B
```

alors seulement construire le reste du système.
