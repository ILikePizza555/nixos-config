{ config, pkgs, ... }:

{
	imports = [
		./hardware-configuration.nix
	];

	# Use the systemd-boot EFI boot loader.
	boot = {
		loader = {
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
		};
	};

	environment = {
		systemPackages = [
			pkgs.git
			pkgs.ripgrep
		];
	};

	networking = {
		hostName = "vm-goth-pinkie-pie";
		firewall = {
			allowedTCPPorts = [22];
		};
	};

	nix = {
		package = pkgs.nixFlakes;
		extraOptions = ''experimental-features = nix-command flakes'';
	};

	programs = {
		fish = {
			enable = true;
		};
	};

	services = {
		openssh.enable = true;
	};

	time = {
		timeZone = "America/Los_Angeles";
	};

	users = {
		defaultUserShell = pkgs.fish;

		users.izzylan = {
			isNormalUser = true;
			description = "Izzy Lancaster personal account";
			extraGroups = ["wheel"];
			openssh.authorizedKeys.keyFiles = [
				../../keys/izzylan/pinkie-pie
				../../keys/izzylan/ipad
			];
		};
	};

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "22.05"; # Did you read the comment?

}

