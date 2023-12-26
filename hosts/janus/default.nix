{ conifg, pkgs, nixos-wsl, ... }:

{
	imports = [
		../base.nix
	];

	networking = {
		hostName = "janus";
		firewall = {
			allowedTCPPorts = [22];
		};
	};
	
	services = {
		tailscale = {
			enable = true;
			useRoutingFeatures = "server";
			extraUpFlags = [
				"--ssh"
				"--advertise-routes=192.168.86.0/24"
			];
		};
	};

	system.stateVersion = "23.11";

	users = {
		users.izzylan = {
			isNormalUser = true;
			description = "Izzy Lancaster personal account";
			extraGroups = ["wheel"];
			hashedPassword = "$6$8/VebrSzM62O4ioE$31Y/suGNT.N3vcgXFImz7SbSPi5dHyh4emg2jWJcLvdnMAu5/.lwrGUtxi4MPPGzI.9ewnpVrYlr5On/u2UM10";
			openssh.authorizedKeys.keyFiles = [
				../../keys/izzylan/pinkie-pie
				../../keys/izzylan/ipad
				../../keys/izzylan/izzy-luna-se
				../../keys/izzylan/1pass
			];
		};
	};
}