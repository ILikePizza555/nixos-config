{config, pkgs, ...}:

{
  imports = [
    ../base.nix
    ./hardware-configuration.nix
  ];

  boot = {
    loader.grub.device = "/dev/vda";
  };

  networking = {
    hostName = "nev-systems-nixos";
    firewall = {
      # 22 - Opened for ssh
      # 80 443 - Opened for caddy
      allowedTCPPorts = [22 80 443];
    };
  };

  services = {
    caddy.enable = true;

    openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
    };

    mysql = {
      enable = true;
      package = pkgs.mariadb;
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
			];
		};
  };

  system.stateVersion = "22.05";
}
