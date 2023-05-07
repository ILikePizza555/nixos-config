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
			url = "github:kiwiirc/kiwiirc/v1.6.1";
			flake = false;
		};
	};

	outputs = inputs@{ self, nixpkgs, home-manager, nixos-generators, nev-systems-site, agenix, kiwi-irc-src }:
	let 
		lib = nixpkgs.lib;
		forEachFlakeSystem = callback: lib.genAttrs lib.systems.flakeExposed (system: 
			let pkgs = nixpkgs.legacyPackages.${system}; in 
			callback system pkgs
		);
	in
	{
		packages = forEachFlakeSystem (system: pkgs: {
			install-iso = nixos-generators.nixosGenerate {
				inherit system;
				modules = [
					./hosts/base.nix
					./profiles/neovim.nix
				];
				format = "install-iso";
			};

			kiwiirc-client = pkgs.yarn2nix-moretea.mkYarnPackage {
				name = "kiwiirc-client";
				src = kiwi-irc-src;
				# Need node options to fix https://stackoverflow.com/questions/69394632/webpack-build-failing-with-err-ossl-evp-unsupported
				# Using openssl-legacy-provider shouldn't matter for building what is essentially a static site
				buildPhase = ''
					NODE_OPTIONS=--openssl-legacy-provider yarn run build
				'';
				installPhase = ''
					runHook preInstall

					mkdir $out
					mv -t $out deps/$pname/dist/*

					runHook postInstall
					'';
				postInstall = ''
					rm $out/static/config.json
				'';
				doDist = false;
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

			villainous = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				specialArgs = inputs;
				modules = [
					./hosts/villainous
					./profiles/neovim.nix
				];
			};
		};
	};
}
