{config, pkgs, ...}:
let
  domain = "git.nev.systems";
in
{
  services = {
    caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy http://localhost:3000
    '';

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
