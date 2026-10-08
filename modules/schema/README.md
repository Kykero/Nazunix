# modules/schema/

Extensions to den's host schema: the `profile` option and what it does.

| File | What it does |
|---|---|
| `profile.nix` | adds `profile` to every host: `"base"` (bootable minimum, cache-friendly) or `"full"` (complete environment), default `"full"` |
| `profile-pointcut.nix` | makes every host include `den.aspects."profile-${host.profile}"` |

Together they mean a host gets its profile from one line in
[`../hosts.nix`](../hosts.nix) (`profile = "base";` for the `-base`
gateways, nothing for the full entities) and no host wires a profile by
hand. The profile aspects themselves are in
[`../profiles/`](../profiles/README.md).
