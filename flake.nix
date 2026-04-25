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
        # Read hardware config from a fixed path on the box at build time.
        # --impure is required because we're reading outside the flake.
        /etc/nixos/hardware-configuration.nix
      ];
    };
  };
}
