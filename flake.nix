{
  description = "The flake managing my servers";

  inputs = {
    # NixOS official package source, using the nixos-23.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, microvm, ... }@inputs: {

    #
    # Hosts
    #

    # VM Testing Host
    nixosConfigurations.protoserver = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        microvm.nixosModules.host
        ./lib/base-ssh.nix
        ./hosts/protoserver/configuration.nix
        {
          microvm.host.enable = true;
          microvm.vms.guest0 = {
            flake = self;
            updateFlake = "/root/nix-systems";
          };
        }
      ];
    };

    # Intel NUC at home
    nixosConfigurations.nucsrv = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        microvm.nixosModules.host
        ./lib/base-ssh.nix
        ./hosts/nucsrv/configuration.nix
        {
          microvm.host.enable = true;
          microvm.vms.guest0 = {
            flake = self;
            updateFlake = "/root/nix-systems";
          };

          # don't change this, unless you have a really good reason
          system.stateVersion = "24.05"; # Did you read the comment?
	}
      ];
    };

    #
    # Guests
    #

    # A test guest
    nixosConfigurations.guest0 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        microvm.nixosModules.microvm
        ./lib/base-ssh.nix
        {
          networking.hostName = "guest0";
          system.stateVersion = "24.05";

          microvm.shares = [{
            source = "/nix/store";
            mountPoint = "/nix/store";
            tag = "ro-store";
            proto = "virtiofs";
          }];

          microvm.interfaces = [ {
            type = "tap";
						id = "vm-guest0";
						mac = "02:00:00:00:00:01";
          } ];
        }
      ];
    };
  };
}
