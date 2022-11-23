{ config, pkgs, nixos-generators, ... }:

{
	imports = [
    ../base.nix
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
      nixos-generators.defaultPackage.${pkgs.system}
      pkgs.mosh
    ];
  };

	networking = {
		hostName = "vm-goth-pinkie-pie";
		firewall = {
      allowedTCPPorts = [22];
      allowedTCPPortRanges = [
        { from = 1000; to = 1500; }
      ];
		};
	};

	services = {
    tailscale.enable = true;
		openssh.enable = true;
	};

	users = {
		users.izzylan = {
			isNormalUser = true;
			description = "Izzy Lancaster account";
			extraGroups = ["wheel"];
			openssh.authorizedKeys.keyFiles = [
				../../keys/izzylan/pinkie-pie
				../../keys/izzylan/ipad
			];
		};
	};

  virtualisation = {
    hypervGuest.enable = true;
  };

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "22.05"; # Did you read the comment?

}

