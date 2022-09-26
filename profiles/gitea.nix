{config, pkgs, ...}:
let
  giteaUsername = "gitea";
  giteaDBName = "gitea";
in
{
  networking = {
    firewall.allowedTCPPorts = [80,443];
  };

  services = {
    mysql = {
      ensureDatabases = [giteaDBName]; 

      ensureUsers = {
        name = giteaUsername;
        ensurePermissions = {
          "${giteaDBName}.*" = "ALL PRIVILEGES";
        };
      };
    };

    gitea = {
      enable = true;
      useWizard = true;
      domain = "git.nev.systems";

      database = {
        type = "mysql";
        name = giteaDBName;
        # Magic socket location, because it's not defined in the nixos config.
        socket = "/run/mysqld/mysqld.sock";
      };
    };
  };
}
