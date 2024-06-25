{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    purescript-overlay = {
      url = "github:thomashoneyman/purescript-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.latitude = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./nixos/shared/configuration.nix
        ./nixos/custom/latitude/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ola = import ./home-manager/shared/home.nix;
        }
        ({ nixpkgs.overlays = [ inputs.purescript-overlay.overlays.default ]; })
      ];
    };

    nixosConfigurations.yoga = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./nixos/custom/yoga/configuration.nix
        ./nixos/shared/configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ola = import ./home-manager/shared/home.nix;
        }
        ({ nixpkgs.overlays = [ inputs.purescript-overlay.overlays.default ]; })
      ];
    };
  };

}
