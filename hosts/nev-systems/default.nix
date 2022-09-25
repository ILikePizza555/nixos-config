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
      allowedTCPPorts = [22 80 443 6667 6697];
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
      hashedPassword = "$6$Lp7QUACZYJqIhOUA$IfdR5NX7.qQVf85M.m7S3ZWvIlDPsmG2i11S5MsmvPbK5140k8LenORAiFtNP9x4vssomGi6uGdpPccQzCwsu/";
			openssh.authorizedKeys.keyFiles = [
				../../keys/izzylan/pinkie-pie
				../../keys/izzylan/ipad
			];
		};
  };

  system.stateVersion = "22.05";
}
