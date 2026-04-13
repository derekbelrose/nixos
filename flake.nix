{
  description = "NixOS fleet flake with disko";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";

    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, disko, ... }:
    let
      mkHost = hostPath:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            hostPath
          ];
        };
    in
    {
      nixosConfigurations = {
        proxmox-vm = mkHost ./hosts/proxmox-vm;
        baremetal-01 = mkHost ./hosts/baremetal-01;
      };
    };
}
