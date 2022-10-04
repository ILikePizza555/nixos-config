{config, ...}:

# TODO: Make this into a module, it's complicated enough that it should be one

let
  host = "irc.nev.systems";
  certCfg = config.security.acme.certs.${host};
  tls = {
    cert = certCfg.directory + "/cert.pem";
    key = certCfg.directory + "/key.pem";
  };
  dbUsername = "ergo";
  dbName = "ergo_history";
in
{
  networking = {
    firewall.allowedTCPPorts = [6697 8087];
  };

  services = {
    ergochat = {
      enable = true;
      settings = {
        accounts = {
          authentication-enabled = true;
          registration.enabled = false;
          require-sasl.enabled = true;
        };
        datastore.mysql = {
          enabled = true;
          socket-path = /run/mysqld/mysqld.sock;
          user = dbUsername;
          history-database = dbName;
        };
        history = {
          enabled = true;
          persistent = {
            enabled = true;
            direct-messages = "opt-in";
          };
          retention = {
            allow-individual-delete = true;
            enable-account-indexing = true;
          };
        };
        server = {
          name = "irc.nev.systems";
          listeners = {
            # Localhost listeners for administration
            "127.0.0.1:6667" = {};
            "[::1]:6667" = {};

            ":6697" = {
              inherit tls;
              proxy = false;
              min-tls-version = 1.2;
            };

            # Websocket listner
            ":8097" = {
              websocket = true;
              inherit tls;
            };
          };
          sts.enabled = true;
          websockets.allowed-origins = [ host ];
        };
        roleplay.enabled = true;
      };
    };

    mysql = {
      ensureDatabases = [ dbName ];
      ensureUsers = [
        {
          name = dbUsername;
          ensurePermissions = {
            "${dbName}.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    nginx.virtualHosts.${host} = {
      enableACME = true;
      locations."/" = {
        return = "204";
      };
    };
  };
}