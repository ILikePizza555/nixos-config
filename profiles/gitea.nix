{config, pkgs, ...}:
let
  domain = "git.nev.systems";
in
{
  services = {
    nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3000";
      };
    };

    gitea = {
      enable = true;
      rootUrl = "https://${domain}/";
      disableRegistration = true;

      # Gitea module automatically sets `services.mysql.ensureDatabases` and `services.mysql.ensureUsers`
      database = {
        type = "mysql";
        # Magic socket location, because it's not defined in the nixos config.
        socket = "/run/mysqld/mysqld.sock";
      };
    };
  };
}
