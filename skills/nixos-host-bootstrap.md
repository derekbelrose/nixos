# Skill: NixOS Host Bootstrap

## Metadata

- Skill: `nixos-host-bootstrap`
- Version: `1.0`
- Scope: `host-specific`

## Purpose

Provision a host from the NixOS installer ISO using the repo's host profile and disko layout.

## When To Use

- Initial install for `proxmox-vm`, `baremetal-01`, or a newly added host.
- Reinstall where disk layout should match `hosts/<host>/disko.nix`.

## Inputs

- Host name: `<host>`
- Target disk device (for `my.disko.device`): `/dev/sda`, `/dev/nvme0n1`, or similar

## Preconditions

- Booted into NixOS installer ISO with network access.
- Repo is available on the installer system.
- Host has `hosts/<host>/default.nix` and `hosts/<host>/disko.nix`.

## Procedure

1. Confirm network is up and open the repo on the installer environment.
2. Set or confirm `my.disko.device` in host config if non-default disk is needed.
3. Apply partitioning and filesystems:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./hosts/<host>/disko.nix
```

4. Install the host profile:

```bash
sudo nixos-install --flake .#<host>
```

5. Reboot into installed system.

## Validation

- Run:

```bash
hostnamectl
systemctl status tailscaled --no-pager
```

- Confirm hostname matches target host and `tailscaled` is active.

## Done Criteria

- Host boots into installed system.
- Network is up and host is reachable.
- `tailscaled` is active.

## Notes

- Disk defaults are documented in `README.md`; override only when needed.
