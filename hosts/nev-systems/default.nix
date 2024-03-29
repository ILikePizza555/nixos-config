{config, pkgs, nev-systems-site, ...}:

{
  imports = [
    ../base.nix
    ./hardware-configuration.nix
  ];

  age = {
    secrets = {
      namecheapApi.file = ../../secrets/namecheapapi-nev-systems.age;
    };
  };

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
    openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
    };

    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        "nev.systems" = {
          # Use the wildcard certificate
          useACMEHost = "nev.systems";
          forceSSL = true;
          root = nev-systems-site.packages.${pkgs.system}.default;
        };
      };
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
      defaults.email = "avrisaac555+acme-nev-systems@gmail.com";
      certs."nev.systems" = {
        domain = "*.nev.systems";
        extraDomainNames = ["nev.systems"];
        dnsProvider = "namecheap";
        credentialsFile = config.age.secrets.namecheapApi.path;
      };
    };
  };
  
  system.stateVersion = "22.05";
}
