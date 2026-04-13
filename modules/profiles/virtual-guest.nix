{ lib, ... }:
{
  services.qemuGuest.enable = true;

  # Sensible defaults for virtualized Linux guests.
  boot.initrd.availableKernelModules = lib.mkDefault [
    "ahci"
    "sr_mod"
    "virtio_blk"
    "virtio_pci"
    "virtio_scsi"
    "xhci_pci"
  ];
}
