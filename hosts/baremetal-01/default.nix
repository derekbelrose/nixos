{ lib, ... }:
{
  imports = [
    ../../modules/base.nix
    ./disko.nix
  ];

  networking.hostName = "baremetal-01";

  # Override per-host when the boot disk differs.
  my.disko.device = lib.mkDefault "/dev/nvme0n1";
}
