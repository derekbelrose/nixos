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

  # On this Proxmox test VM, use deterministic kernel block paths in stage-1
  # instead of by-partlabel symlinks to avoid initrd udev timing issues.
  fileSystems."/" = lib.mkForce {
    device = "/dev/sda3";
    fsType = "ext4";
  };

  swapDevices = lib.mkForce [
    { device = "/dev/sda2"; }
  ];

  # Override per-host when the boot disk differs.
  my.disko.device = lib.mkDefault "/dev/sda";
}
