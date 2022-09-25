{config, pkgs}:

{
  imports = [
    ../base.nix
  ];

  networking = [
    hostName = "nev-systems";
    firewall = {
      allowedTCPPorts = [22, 80, 443, 6667 6697];
    };
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
    }
  };

  users = {
    defaultUserShell = pkgs.fish; 
    mutableUsers = false;

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

  system.stateVersion = "22.05";
}
