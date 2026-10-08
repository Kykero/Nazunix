# modules/users/

User aspects. A user attached to a host in [`../hosts.nix`](../hosts.nix)
(`users.nazuna = { };`) gets the aspect of the same name from here.

| File | Aspect | What it does |
|---|---|---|
| `nazuna.nix` | `nazuna` | creates the account (`define-user`, `primary-user` batteries: wheel and NetworkManager membership) and adds the bash, btop and fastfetch home aspects |

## Notes

- Home settings are applied through home-manager as a NixOS module, set for
  every user in [`../defaults.nix`](../defaults.nix).
- The login shell, fish, is not listed here: `homes/shell/fish.nix` includes
  it for every user through `den.schema.user.includes`. bash stays for
  scripts and recovery.
- No password is stored in the repo; it is set with `passwd` at the end of
  the install ([docs/install.md](../../docs/install.md)).
