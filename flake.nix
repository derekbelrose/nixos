{
  description = "NixOS fleet flake with disko";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
    openclaw.url = "github:openclaw/nix-openclaw";

    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, disko, openclaw, ... }:
    let
      mkHost = hostPath:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit openclaw;
          };
          modules = [
            disko.nixosModules.disko
            hostPath
          ];
        };
    in
    {
      nixosConfigurations = {
        proxmox-vm = mkHost ./hosts/proxmox-vm;
        agent-server = mkHost ./hosts/agent-server;
        baremetal-01 = mkHost ./hosts/baremetal-01;
      };
    };
}
