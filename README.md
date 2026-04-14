# NixOS Fleet

Baseline flake for managing NixOS hosts with shared modules and host-specific profiles.

## Current Hosts

- `proxmox-vm` (SeaBIOS + q35)
- single-disk disko layout (GPT, BIOS boot partition, 4G swap, ext4 root)
- DHCP networking
- `qemu-guest-agent` enabled
- `tailscale` enabled
- OpenClaw enabled via shared module (`my.openclaw`)

- `agent-server` (SeaBIOS + q35)
- single-disk disko layout (GPT, BIOS boot partition, 4G swap, ext4 root)
- DHCP networking
- `qemu-guest-agent` enabled
- `tailscale` enabled
- OpenClaw enabled via shared module (`my.openclaw`)

- `baremetal-01` (UEFI)
- single-disk disko layout (GPT, 512M ESP, 4G swap, ext4 root)
- DHCP networking
- `tailscale` enabled

## Install (from NixOS ISO)

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./hosts/proxmox-vm/disko.nix
sudo nixos-install --flake .#proxmox-vm
```

For `baremetal-01`, use:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./hosts/baremetal-01/disko.nix
sudo nixos-install --flake .#baremetal-01
```

For `agent-server`, use:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./hosts/agent-server/disko.nix
sudo nixos-install --flake .#agent-server
```

## Notes

- Default disk is `/dev/sda`; override with `my.disko.device` per host.
- `baremetal-01` defaults to `/dev/nvme0n1`; override with `my.disko.device` when needed.
- Keep virtual-only settings in `modules/profiles/virtual-guest.nix`.
- Add future bare-metal hosts by importing `modules/base.nix` without the virtual profile.

## Local Skills

- Start from `SKILL.md` for progressive-disclosure routing.
- See `SKILL-GUIDE.md` for the agent-wide router pattern.
- Validate router structure with `python3 scripts/check_skill_router.py`.
- Pre-commit hook is configured in `.pre-commit-config.yaml` (run `pre-commit install`).
- Reusable repo playbooks live in `skills/`.
- Start with `skills/README.md` to pick the right workflow.

## OpenClaw Module

OpenClaw support lives in `modules/services/openclaw.nix` and is imported via `modules/base.nix`.

Enable per host:

```nix
my.openclaw = {
  enable = true;
  user = "derek";
  # gatewayPort = 18789;
};
```

Verification:

```bash
which openclaw
ls -la ~/.openclaw
stat ~/.openclaw/openclaw-token.txt
systemctl --user status openclaw-gateway
journalctl --user -u openclaw-gateway -n 100
curl -sS http://127.0.0.1:18789
```
