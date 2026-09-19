# opencode skill: add a new UI variant to /etc/nixos (Hyprland family).

## Trigger
When the user asks to "add a ui variant" / "new look" / "make frost/heinz/…"
or to change the current desktop (ui toggling).

## Workflow
1. Read `/etc/nixos/variables.nix` — copy the `ui = "…"` pattern for the new
   variant id (kebab-case, e.g. `peach`).
2. Create `ui/<variant>/`:
   - `default.nix` — NixOS-level system module (greetd/tuigreet + Hyprland +
     portals channels). **Mirror the shape of `ui/frost/default.nix`** and
     point its `home-manager.users.….imports` at `./home.nix`.
   - `home.nix` — thin Home-Manager module: `imports = [
     ../shared/home-shared.nix  ../shared/hyprland-home.nix ]` plus the few
     variant-specific packages (terminal, launcher, notifier, accent color).
3. Register it in `/etc/nixos/flake.nix` `uiModules` map.
4. Add the accent/term/accent overrides to `variables.nix` if you need them
   (the shared modules default them, so only add if the variant differs).

## Hard rules picked from this repo's own history (do NOT regress)
- Keep shared, cross-variant GTK/icon theming in `ui/shared/home-shared.nix`
  ONLY — never duplicate a `gtk = {…}` block in two shared modules (causes a
  strict definition conflict at merge time).
- Keep every accent-derived string escaped with `''…''` dollar-heredocs that
  interpolate via `"" ${accent} ""` concatenation, never a raw `${` inside a
  file you also want to keep — Nix will try to evaluate it as a string escape.
- `ui/shared/hyprland-home.nix` = the shared Hyprland HOME userland (dotfiles,
  waybar, swaync, hypridle/lock, tofi). Do NOT grow variant home.nix beyond
  ~15 lines; everything reusable lives in the two `ui/shared/*` files.
- One package-existence rule: only add a `pkgs.X` you verified exists in the
  current nixpkgs (e.g. `grep`able from `nix eval`), and prefer
  `swaynotificationcenter` over `swaync` if unsure.

## Verify (ALWAYS)
```
cd /etc/nixos && git add -A && nix flake check
```
Then flip `variables.nix` `ui` to the new variant and run `nix flake check`
again to make sure the variant actually evaluates. Only then `nixos-rebuild
switch --flake /etc/nixos`.
