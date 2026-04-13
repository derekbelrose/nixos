{ lib, ... }:
{
  services.qemuGuest.enable = true;

  # Sensible defaults for virtualized Linux guests.
  boot.initrd.availableKernelModules = lib.mkDefault [
    "ahci"
    "scsi_mod"
    "sd_mod"
    "sr_mod"
    "virtio_blk"
    "virtio_pci"
    "virtio_scsi"
    "xhci_pci"
  ];

  boot.initrd.kernelModules = lib.mkDefault [
    "ext4"
    "scsi_mod"
    "sd_mod"
    "virtio_pci"
    "virtio_scsi"
  ];
}
