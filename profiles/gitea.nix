{config, pkgs, ...}:
let
  giteaUsername = "gitea";
  giteaDBName = "gitea";
  domain = "git.nev.systems";
in
{
  networking = {
    firewall.allowedTCPPorts = [80 443];
  };

  services = {
    caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy http://localhost:3000
    '';

    mysql = {
      ensureDatabases = [giteaDBName]; 

      ensureUsers = [
        {
          name = giteaUsername;
          ensurePermissions = {
            "${giteaDBName}.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    gitea = {
      enable = true;
      useWizard = true;
      inherit domain;

      database = {
        type = "mysql";
        name = giteaDBName;
        # Magic socket location, because it's not defined in the nixos config.
        socket = "/run/mysqld/mysqld.sock";
      };
    };
  };
}
