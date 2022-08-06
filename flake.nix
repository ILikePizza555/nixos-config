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
        ./hosts/goth-pinkie-pie
      ];
    };
  };
}
