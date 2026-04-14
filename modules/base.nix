{ lib, pkgs, ... }:
{
  imports = [
    ./services/openclaw.nix
  ];

  networking.useDHCP = lib.mkDefault true;

  time.timeZone = lib.mkDefault "UTC";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  services.openssh.enable = true;
  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  system.stateVersion = "25.05";
}
