{
    description = "A simple NixOS flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

        home-manager = {
            url = "github:nix-community/home-manager/release-23.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = {self, nixpkgs, home-manager, ...}@inputs: {
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ 
                ./nixos/configuration.nix 
                home-manager.nixosModules.home-manager {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.users.ola = import ./home-manager/home.nix;
                }
            ];
        };
    };

}
