{
	inputs = {
		nixpkgs.url = github:NixOS/nixpkgs;
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
     nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixos-generators }:
  {
    nixosConfigurations = {
      vm-goth-pinkie-pie = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./hosts/goth-pinkie-pie
          ./profiles/neovim.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.izzylan = import ./users/izzylan.nix;
            };
          }
        ];
      };

      nev-systems = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./hosts/nev-systems
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.izzylan = import ./users/izzylan.nix;
            };
          }
        ];
      };
    };
  };
}
