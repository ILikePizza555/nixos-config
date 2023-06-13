{ config, pkgs, ... }:

{
	imports = [
		../base.nix
		./hardware-configuration.nix
	];

	age = {
		secrets = {
			namecheapApi.file = ../../secrets/namecheapapi-r196-club.age;
		};
	};

	boot = {
		loader.grub.device = "/dev/vda";
	};

	networking = {
		hostName = "r196-club";
		firewall = {
			# 22 - Opened for ssh
			# 80 443 - Opened for web
			allowedTCPPorts = [22 80 443];
		};
	};

	nixpkgs = {
		overlays = [
			(final: prev: { lemmy-ui = prev.lemmy-ui.override { nodejs = pkgs.nodejs_18; }; })
		];
	};

	services = {
		caddy = {
			virtualHosts = {
				"r196.club" = {
					useACMEHost = "r196.club";
				};
			};
		};

		lemmy = {
			enable = true;
			caddy.enable = true;
			database.createLocally = true;
			settings = {
				hostname = "r196.club";
			};
		};

		openssh = {
			enable = true;
			passwordAuthentication = false;
			permitRootLogin = "no";
		};
	};

	users = {
		mutableUsers = false;

		users.izzylan = {
			isNormalUser = true;
			description = "Izzy Lancaster personal account";
			extraGroups = ["wheel"];
			hashedPassword = "$6$niQq4PEbx7nyMvH/$WNrexM4za/YwX7a.ksaHKyLf7k1vI31mqZJ7Dip.rGSkNUOy7TZ3P1iNXlCCKsJx0iGGcJAtpLnHkfXOn.zTb/";
			openssh.authorizedKeys.keyFiles = [
				../../keys/izzylan/pinkie-pie
				../../keys/izzylan/ipad
				../../keys/izzylan/izzy-luna-se
			];
		};
	};

	security = {
		acme = {
			acceptTerms = true;
			defaults.email = "avrisaac555+acme-r196-club@gmail.com";
			certs."r196.club" = {
				domain = "*.r196.club";
				extraDomainNames = ["r196.club"];
				dnsProvider = "namecheap";
				credentialsFile = config.age.secrets.namecheapApi.path;
			};
		};
	};

	system.stateVersion = "23.05";
}