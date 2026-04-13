{ lib, ... }:
{
  imports = [
    ../../modules/base.nix
    ../../modules/profiles/virtual-guest.nix
    ./disko.nix
  ];

  networking.hostName = "proxmox-vm";

  # Give udev extra time to populate /dev/disk/by-partlabel in early boot.
  boot.kernelParams = [ "rootwait" ];

  # Override per-host when the boot disk differs.
  my.disko.device = lib.mkDefault "/dev/sda";
}
