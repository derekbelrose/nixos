# Skill: Add New Host

## Metadata

- Skill: `nixos-add-host`
- Version: `1.0`
- Scope: `repo-wide`

## Purpose

Add a new machine profile to the fleet with consistent module and disk layout conventions.

## When To Use

- Introducing a new VM or bare-metal node.
- Splitting an existing generic profile into a host-specific profile.

## Inputs

- New host name: `<new-host>`
- Platform type: `virtual` or `bare-metal`
- Target disk device for install: `/dev/sda`, `/dev/nvme0n1`, or similar

## Preconditions

- `modules/base.nix` remains the common baseline.
- Chosen platform boot mode is known (BIOS vs UEFI).

## Procedure

1. Create host directory:

```bash
mkdir -p hosts/<new-host>
```

2. Add `hosts/<new-host>/default.nix`:

- Import `../../modules/base.nix`.
- Set `networking.hostName = "<new-host>"`.
- Set `my.disko.device` for target hardware.
- Import `./disko.nix`.
- Add `../../modules/profiles/virtual-guest.nix` only for virtual guests.

3. Add `hosts/<new-host>/disko.nix`:

- Use BIOS or UEFI layout appropriate for the host.
- Keep swap and filesystem defaults consistent unless requirements differ.

4. Register host in `flake.nix` under `nixosConfigurations`.
5. Update `README.md` with host hardware and layout notes.
6. Validate evaluation and host build:

```bash
nix flake show
nix build .#nixosConfigurations.<new-host>.config.system.build.toplevel
```

## Validation

- Confirm `<new-host>` appears in `nix flake show` output.
- Confirm host toplevel build succeeds.
- Confirm docs include host-specific defaults.

## Done Criteria

- New host is wired in `flake.nix`.
- Host configuration builds successfully.
- Repo docs reflect the new host.

## Notes

- Prefer explicit host defaults over implicit installer-time assumptions.
