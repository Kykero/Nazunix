# Keyboard (AZERTY) in niri

niri binds match the unshifted keysym, so the defaults are transposed in
`modules/desktop/niri-binds.nix`: workspaces on `Mod` + the number row as
printed (`& é " ' ( - è _ ç`), hotkey overlay on `Mod+Shift+:`, column
width on `Mod+)` / `Mod+=`, consume/expel on `Mod+^` / `Mod+$`.

| Keys | Action |
|---|---|
| `Mod+T`, `Ctrl+Alt+T` | terminal (ghostty) |
| `Mod+Space` | Noctalia launcher |
| `Mod+I` | Noctalia settings |
| `Super+Alt+L` | lock |
| `Ctrl+Alt+Delete` | Noctalia session menu (lock, log out, suspend, reboot, shut down) |
| `Mod+Shift+E` | quit niri (works even if Noctalia is down) |

`Mod+I` no longer moves one workspace up: use `Mod+Page_Up`.
