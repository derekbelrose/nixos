{ config, lib, ... }:
let
  cfg = config.my.disko;
in
{
  options.my.disko.device = lib.mkOption {
    type = lib.types.str;
    default = "/dev/sda";
    description = "Disk device used by disko for this host.";
  };

  config.disko.devices = {
    disk.main = {
      type = "disk";
      device = cfg.device;
      content = {
        type = "gpt";
        partitions = {
          bios = {
            size = "1M";
            type = "EF02";
          };

          swap = {
            size = "4G";
            content = {
              type = "swap";
            };
          };

          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };

  boot.loader.grub = {
    enable = true;
    device = cfg.device;
  };
}
