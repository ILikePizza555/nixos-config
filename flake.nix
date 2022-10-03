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
    nev-systems-site = {
      url = "git+https://git.nev.systems/izzylan/nev-systems-site.git?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixos-generators, nev-systems-site }:
  {
    # Install iso with 
    packages.x86_64-linux.install-iso = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      modules = [
        ./hosts/base.nix
        ./profiles/neovim.nix
      ];
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
        modules = [
          ./hosts/nev-systems
          ./profiles/neovim.nix
          ./profiles/gitea.nix
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
