{ lib, ... }:
{
  imports = [
    ../../modules/base.nix
    ../../modules/profiles/virtual-guest.nix
    ./disko.nix
  ];

  networking.hostName = "agent-server";

  users.users.derek = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAwZk9cO3UssUrAfYuTYa6xeoZZYZMy4GMSu97eLSq1V derek@rover"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  my.openclaw = {
    enable = true;
    user = "derek";
  };

  # Give udev extra time to populate /dev/disk/by-partlabel in early boot.
  boot.kernelParams = [ "rootwait" ];

  # Force critical storage drivers in stage-1 so the Proxmox disk shows up
  # before root/swap mounts are attempted.
  boot.initrd.kernelModules = lib.mkForce [
    "dm_mod"
    "ext4"
    "scsi_mod"
    "sd_mod"
    "virtio_pci"
    "virtio_scsi"
  ];

  boot.initrd.availableKernelModules = lib.mkForce [
    "ahci"
    "ext4"
    "scsi_mod"
    "sd_mod"
    "sr_mod"
    "virtio_blk"
    "virtio_pci"
    "virtio_scsi"
    "xhci_pci"
  ];

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
