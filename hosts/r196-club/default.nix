{ config, pkgs, lib, ... }:

let
	lemmyDbName = "lemmy";
	lemmyDbUserName = "lemmy";
in
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
			database.createLocally = false;
			settings = {
				database = {
					user = lemmyDbName;
					host = "/run/postgresql";
					port = 5432;
					database = lemmyDbUserName;
					pool_size = 5;
				};
				hostname = "r196.club";
			};
		};

		openssh = {
			enable = true;
			passwordAuthentication = false;
			permitRootLogin = "no";
		};

		postgresql = {
			enable = true;
			ensureDatabases = [ lemmyDbName ];
			ensureUsers = [{
				name = lemmyDbUserName;
				ensurePermissions."DATABASE ${lemmyDbUserName}" = "ALL PRIVILEGES";
			}];
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

	systemd = {
		services.lemmy.environment.LEMMY_DATABASE_URL = lib.mkForce "postgresql://${lemmyDbUserName}:5432@/${lemmyDbName}?host=/run/postgresql";
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
}