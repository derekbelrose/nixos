# Skill: NixOS Change Validation

## Metadata

- Skill: `nixos-host-validate`
- Version: `1.0`
- Scope: `repo-wide`

## Purpose

Validate that configuration changes evaluate and build cleanly before deployment.

## When To Use

- Before committing host or shared module edits.
- After making changes to ensure no regressions.

## Inputs

- Change scope: `all-hosts` or single `<host>`
- Optional target host for focused checks: `<host>`

## Preconditions

- Nix with flakes is available in local environment.
- Working tree contains intended changes.

## Procedure

1. Confirm flake evaluates:

```bash
nix flake show
```

2. Build affected host configurations (no switch). For full validation run:

```bash
nix build .#nixosConfigurations.proxmox-vm.config.system.build.toplevel
nix build .#nixosConfigurations.baremetal-01.config.system.build.toplevel
```

3. If the change is host-specific, build only that host configuration.
4. For disko edits, run a format-mode dry review:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode format ./hosts/<host>/disko.nix
```

5. Re-run relevant build commands after final edits.
6. Review diff for unexpected changes, especially `flake.lock`.

## Validation

- Confirm all executed `nix build` commands complete successfully.
- Confirm `nix flake show` returns expected `nixosConfigurations`.
- Confirm only intended files changed.

## Done Criteria

- Flake evaluation passes.
- Expected host build(s) succeed.
- No unintended file drift remains.

## Notes

- Prefer host-targeted builds for quick feedback during iteration.
