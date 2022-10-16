{config, ...}:

let
  host = "irc.nev.systems";
  useACMEHost = "nev.systems";
in
{
  imports = [
    ../modules/ergochat-redux.nix
  ];

  networking = {
    firewall.allowedTCPPorts = [6697 8087];
  };

  services = {
    ergochat-redux = {
      enable = true;
      accounts = {
        authentication-enabled = true;
        registration.enabled = false;
        require-sasl.enabled = true;
      };
      datastore.mysql = {
        enabled = true;
        ensureDB = true;
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
      opers = {
        admin = {
          class = "server-admin";
          whois-line = "Is the server administrator";
          hidden = true;
          passwordHash = "$2a$04$3opB87SWx7rgwSt8Y0/RE.zZtoDSij93qaIDTkqxg8edExECCMDWK";
        };
      };
      server = {
        name = "irc.nev.systems";
        listeners = {
          # Localhost listeners for administration
          "127.0.0.1:6667" = {};
          "[::1]:6667" = {};

          ":6697" = {
            inherit useACMEHost;
          };

          # Websocket listner
          ":8097" = {
            websocket = true;
            inherit useACMEHost;
          };
        };
        sts.enabled = true;
        websocketsAllowedOrigins = [ host ];
        enforce-utf8 = true;
      };
      roleplay.enabled = true;
    };

    nginx.virtualHosts.${host} = {
      inherit useACMEHost;
      locations."/" = {
        return = "204";
      };
    };
  };
}
