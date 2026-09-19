# NixOS configuration (flake) — `/etc/nixos`

Personal NixOS 25.05 configuration with pluggable **UI variants** (and a
self-hosted **opencode skill** for adding new ones).

## Quickstart

```console
$ sudo nix flake check          # validate the whole flake
$ sudo nixos-rebuild switch --flake .#nixos
```

## Switching the desktop

Edit **`variables.nix`** → `ui`, then rebuild:

| `ui`  | Desktop                        | Terminal | Launcher | Notifier |
|-------|--------------------------------|----------|----------|----------|
| `gnome`| Stock GNOME (GDM)              | —        | —        | —        |
| `nixy`| Hyprland Hyprland style        | ghostty  | tofi     | swaync   |
| `heinz`| Hyprland (HeinzDev style)      | kitty    | rofi     | dunst    |
| `frost`| Hyprland (Frost-Phoenix style) | ghostty  | rofi     | swaync   |

## Layout

```
flake.nix                top-level wiring (uiModules, specialArgs, users)
variables.nix            HARDCODE ui = "..." + username/hostname/stateVersion
modules/                 shared system + home-manager modules (independent of ui)
ui/<variant>/default.nix variant system module (greetd/Hyprland/portals)
ui/<variant>/home.nix    variant home-manager module (thin — imports shared)
ui/shared/               shared HM + system building blocks (inherit logic lives here)
ui/gnome/                stock GNOME + GDM default
```

## Adding a new variant

Use the skill:

```console
$ opencode            # then ask: "add a ui variant called <name>, accent <col>"
```

or call the bundled skill file directly (see `skills/add-ui-variant/`).

## Notes

- Need the `nixos` user in group `wheel`, plus
  `nix.settings.trusted-users = [ "root" "@wheel" ]`.
- HM modules receive `variables` via `home-manager.extraSpecialArgs`,
  so keep key strings (`term`, `launcher`, `accent`) in `variables.nix` if
  you want variants to share them.
