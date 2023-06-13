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
  };

  system.stateVersion = "23.05";
}