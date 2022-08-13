{
	inputs = {
		nixpkgs.url = github:NixOS/nixpkgs;
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager }: {
    nixosConfigurations."vm-goth-pinkie-pie" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [
        ./modules/base.nix
        ./hosts/goth-pinkie-pie
        ./modules/neovim.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.users.izzylan = {config, pkgs, ...}:
          {
            home = {
              username = "izzylan";
              homeDirectory = "/home/izzylan";
              stateVersion = "22.05";
            };

            programs = {
              git = {
                enable = true;
                userName = "izzylan";
                userEmail = "avrisaac555@gmail.com";
              };

              home-manager = {
                enable = true;
              };
            };
          };
        }
      ];
    };
  };
}
