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
			hashedPassword = "$6$2jTbqagpP2iqzvFR$5Rm/2tc0atsHbtt6iHM5D0BZmbBD612CvlgrlC/ZjUwr3u0MNG/KJxc9ai67qvhxlTX7CM5vf7SU7It.mVbcv0";
			openssh.authorizedKeys.keyFiles = [
				../../keys/izzylan/pinkie-pie
				../../keys/izzylan/ipad
				../../keys/izzylan/izzy-luna-se
			];
		};

		users.nginx = {
      extraGroups = ["acme"];
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