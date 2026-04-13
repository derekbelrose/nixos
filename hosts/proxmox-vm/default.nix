{ lib, ... }:
{
  imports = [
    ../../modules/base.nix
    ../../modules/profiles/virtual-guest.nix
    ../../disko/proxmox-vm.nix
  ];

  networking.hostName = "proxmox-vm";

  # Override per-host when the boot disk differs.
  my.disko.device = lib.mkDefault "/dev/sda";
}
