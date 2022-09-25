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
  let
    nev-systems-modules = [
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
  in
  {
    packages.x86_64-linux."nev-systems-install-iso" = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = nev-systems-modules;
      format = "install-iso";
    };

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
        modules = nev-systems-modules;
      };
    };
  };
}
