{
	inputs = {
		nixpkgs.url = github:NixOS/nixpkgs;
    agenix = {
      url = github:ryantm/agenix;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # For building my custom nixos install iso
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 
    # For building nev-systems system
    nev-systems-site = {
      url = "git+https://git.nev.systems/izzylan/nev-systems-site.git?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kiwi-irc-src = {
      url = "github:kiwiirc/kiwiirc";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixos-generators, nev-systems-site, agenix, kiwi-irc-src }:
  let 
    lib = nixpkgs.lib;
    forEachFlakeSystem = lib.genAttrs lib.systems.flakeExposed;
  in
  {
    packages = forEachFlakeSystem (system: {
      install-iso = nixos-generators.nixosGenerate {
        inherit system;
        modules = [
          ./hosts/base.nix
          ./profiles/neovim.nix
        ];
        format = "install-iso";
      };

      kiwiirc-client = nixpkgs.${system}.yarn2nix.mkYarnPackage {
        name = "kiwiirc-client";
        src = kiwi-irc-src;
      };
    });

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
          agenix.nixosModule
          ./profiles/neovim.nix
          ./profiles/gitea.nix
          ./profiles/ircd-ergo.nix
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
