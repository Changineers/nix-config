{
  description = "dev box";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    workmux.url = "github:raine/workmux";
  };

  outputs = { self, nixpkgs, workmux, ... }: {
    nixosConfigurations.dev = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit workmux; };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };
  };
}
