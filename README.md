# NixOS Fleet

Baseline flake for managing NixOS hosts with shared modules and host-specific profiles.

## Current Host

- `proxmox-vm` (SeaBIOS + q35)
- single-disk disko layout (GPT, BIOS boot partition, 4G swap, ext4 root)
- DHCP networking
- `qemu-guest-agent` enabled
- `tailscale` enabled

## Install (from NixOS ISO)

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disko/proxmox-vm.nix
sudo nixos-install --flake .#proxmox-vm
```

## Notes

- Default disk is `/dev/sda`; override with `my.disko.device` per host.
- Keep virtual-only settings in `modules/profiles/virtual-guest.nix`.
- Add future bare-metal hosts by importing `modules/base.nix` without the virtual profile.
