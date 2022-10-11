# Custom module for ergochat since the one in nixpkgs doesn't work properly
{config, lib, pkgs, ...}:
let
  mkSubmoduleFromOptions = options: lib.types.submodule { inherit options; };
  mkSubmoduleOption = options: lib.mkOption { type = mkSubmoduleFromOptions options; default = {}; };
  mkSimpleOption = type: default: description: lib.mkOption { inherit type; inherit default; inherit description; };
  cfg = config.services.ergochat-redux;
in
{
  options = with lib; {
    services.ergochat-redux = {
      enable = mkEnableOption (lib.mdDoc "Enable the Ergo IRC daemon.");

      networkName = mkOption {
        default = "ErgoTest";
        type = types.str;
      };

      server = mkSubmoduleOption {
        name = mkOption {
          type = types.str;
          default = "ergo.test";
        };

        listeners = mkOption {
          type = types.attrsOf (mkSubmoduleFromOptions {
            tls = mkOption {
              type = types.nullOr (mkSubmoduleFromOptions {
                cert = mkOption { type = types.path; };
                key = mkOption { type = types.path; };
              });
              default = null;
            };

            min-tls-version = mkSimpleOption types.number 1.2 "The minimum TLS version to use for this lsitener.";
            useACMEHost = mkSimpleOption (types.nullOr types.str) null "The ACME host to get TLS certificates for this listener. This overrides tls options.";
            proxy = mkSimpleOption types.bool false "Whether this listener is being a reverse proxy. (See ergo manual).";
            tor = mkSimpleOption types.bool false "Whether this listener is a tor listener.";
            websocket = mkSimpleOption types.bool false "Whether this listener is a websocket listener. This forces `enforce-utf8` to be true.";
          });
          default = {
            "127.0.0.1:6667" = {};
            "[::1]:6667" = {};
          };
        };

        unix-bind-mode = mkSimpleOption types.int 0777 "The permissions for unix socket listeners";

        tor-listeners = mkSubmoduleOption {
          require-sasl = mkSimpleOption types.bool false "Whether tor clients must authenticate with SASL.";
          vhost = mkSimpleOption types.str "tor-network.onion" "The hostname to be displayed for Tor connections";
          max-connections = mkSimpleOption types.int 64 "The limit of tor connections, 0 is no limit";
          throttle-duration = mkSimpleOption types.str "10m" "limit how many connection attempts are allowed at once";
          max-connections-per-duration = mkSimpleOption types.int 64 "set to 0 to disable throttling";
        };

        sts = mkSubmoduleOption {
          enabled = mkSimpleOption types.bool false "Whether to advertise STS.";
          duration = mkSimpleOption types.str "1mo2d5m" "How long clients should be forced to use TLS for.";
          port = mkSimpleOption types.int 6697 "TLS port, you should be listening on this port";
          preload = mkSimpleOption types.bool false "should clients include this STS policy when they ship their inbuilt preload lists?";
        };

        websocketsAllowedOrigins = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            Restrict the origin of WebSocket connections by matching the "Origin" HTTP
            header. This setting causes ergo to reject websocket connections unless
            they originate from a page on one of the whitelisted websites in this list.
            This prevents malicious websites from making their visitors connect to your
            ergo instance without their knowledge. An empty list means there are no
            restrictions.
          '';
        };

        casemapping = lib.mkOption {
          type = types.enum ["precis" "ascii" "permissive"];
          default = "precis";
        };

        enforce-utf8 = mkSimpleOption types.bool true "Whether the server will preemptively discard non-UTF8 messages.";
        lookup-hostnames = mkSimpleOption types.bool false "Whether to look up user hostnames with reverse DNS";
        forward-confirm-hostnames = mkSimpleOption types.bool true "Whether to confirm hostname lookups";
        check-ident = mkSimpleOption types.bool false "Use ident protocol to get usernames";
        coerce-ident = mkSimpleOption types.str "~u" "ignore the supplied user/ident string from the USER command, always setting user/ident to the following literal value";
        password = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Password to login to the server";
        };
        # TODO: MOTD file goes here

        relaymsg = mkSubmoduleOption {
          enabled = mkSimpleOption types.bool true "Whether relaying using the RELAYMSG command is enabled.";
          separators = mkSimpleOption types.str "/" "Which characters are reserved for relayed nicks?";
          available-to-chanops = mkSimpleOption types.bool true "Can channel operators use RELAYMSG in their channels?";
        };

        proxy-allowed-from = mkSimpleOption (types.listOf types.str) [ "localhost" ] "IP/CIDRs the PROXY command can be used from.";

        webirc = mkOption {
          type = types.listOf (mkSubmoduleFromOptions {
            certfp = mkOption { type = lib.str; };
            password = mkOption { type = lib.str; };
            hosts = mkSimpleOption (types.listOf types.str) [ "localhost" ] "IPs/CIDRs that can use this webirc command";
          });
          default = [];
        };

        max-sendq = mkSimpleOption types.str "96k" "maximum length of clients' sendQ in bytes";

        compatability = mkSubmoduleOption {
          force-trailing = mkSimpleOption types.bool true "Whether the final parameter of some messages be a trailing parameter.";
          send-unprefixed-sasl = mkSimpleOption types.bool true "Don't send SASL messages with the server name as a prefix.";
          allow-truncation = mkSimpleOption types.bool false "Whether long messages should be truncated.";
        };

        ip-limits = mkSubmoduleOption {
          count = mkSimpleOption types.bool true "whether to limit the total number of concurrent connections per IP/CIDR";
          max-concurrent-connections = mkSimpleOption types.int 16 "maximum concurrent connections per IP/CIDR";
          throttle = mkSimpleOption types.bool true "whether to restrict the rate of new connections per IP/CIDR";
          window = mkSimpleOption types.str "10m" "how long to keep track of connections for";
          max-connections-per-window = mkSimpleOption types.int 32 "maximum number of new connections per IP/CIDR within the given duration";
          cidr-len-ipv4 = mkSimpleOption types.int 32 "how wide the CIDR should be for IPv4 (a /32 is a fully specified IPv4 address)";
          cidr-len-ipv6 = mkSimpleOption types.int 64 "how wide the CIDR should be for IPv6 (a /64 is the typical prefix assigned";
          exempted = mkSimpleOption (types.listOf types.str) [ "localhost" ] "IPs/networks which are exempted from connection limits";
          custom-limits = mkOption {
            type = types.attrsOf (mkSubmoduleFromOptions {
              nets = mkOptions { type = types.listOf types.str; };
              max-concurrent-connections = mkOptions { type = types.int; };
              max-connections-per-window = mkOptions { type = types.int; };
            });
            default = {};
          };
        };

        ip-check-script = mkSubmoduleOption {
          enabled = mkSimpleOption types.bool false "Whether to enable the pluggable IP ban mechanism";
          command = mkSimpleOption types.str "" "Command to run the IP ban checking script";
          args = mkSimpleOption (types.listOf types.str) [] "List of args to pass to the command.";    
          kill-timeout = mkSimpleOption types.str "9s" "Timeout for process execution";
          max-concurrency = mkSimpleOption types.int 64 "How many scripts are allowed to run at once. 0 for no limit.";
          exempt-sasl = mkSimpleOption types.bool false "If true, only check anonymous connections";
        };

        ip-cloaking = mkSubmoduleOption {
          enabled = mkSimpleOption types.bool true "Whether to enable IP cloaking";
          enabled-for-always-on = mkSimpleOption types.bool true "Whether to use cloak settings to produce unique hostnames for always-on clients.";
          netname = mkSimpleOption types.str "irc" "fake TLD at the end of the hostname";
          cidr-len-ipv4 = mkSimpleOption types.int 32 "";
          cidr-len-ipv6 = mkSimpleOption types.int 64 "";
          num-bits = mkSimpleOption types.int 64 "Number of bits of hash output to include in the cloaked hostname";
        };

        secure-nets = mkSimpleOption (types.listOf types.str) [] "secure-nets identifies IPs and CIDRs which are secure at layer 3";
        output-path = mkSimpleOption (types.nullOr types.str) null "Where to write files to the disk";
        override-services-hostname = mkSimpleOption (types.nullOr types.str) null "The hostname to be used by services (i.e. NickServ)";
        # max-line-len = mkSimpleOption (types.int) 512 "The maximum (non-tag) length of an IRC line. DO NOT CHANGE THIS ON A PUBLIC SERVER."
        suppress-luser = mkSimpleOption types.bool false "send all 0's as the LUSERS (user counts) output to non-operators";
      };

      datastore = mkSubmoduleOption {
        path = mkSimpleOption types.str "ircd.db" "path to the datastore";
        autoupgrade = mkSimpleOption types.bool true "if the database schema requires an upgrade, `autoupgrade` will attempt to perform it automatically on startup.";
        mysql = mkSubmoduleOption {
          enabled = mkSimpleOption types.bool false "Whether to enable mysql for persistent history.";
          ensureDB = mkSimpleOption types.bool false "Whether to have nix manage the database. This invalidates `host`, `port`, and `socket-path`.";
          host = mkSimpleOption types.str "localhost" "";
          port = mkSimpleOption types.port 3306 "";
          socket-path = mkSimpleOption (types.nullOr types.path) null "";
          user = mkSimpleOption types.str "ergo" "Database user";
          password = mkSimpleOption types.str "hunter2" "Database password";
          history-database = mkSimpleOption types.str "ergo_history" "Database name";
          timeout = mkSimpleOption types.str "3s" "";
          max-conns = mkSimpleOption types.int 4 "";
          conn-max-lifetime = mkOption {
            type = types.nullOr types.str;
            default = null; 
            example = "180s";
          };
        };
      };

      limits = mkSubmoduleOption {
        nicklen               = mkSimpleOption types.int 32   "The max nick length allowed";
        identlen              = mkSimpleOption types.int 20   "The max ident length allowed";
        channellen            = mkSimpleOption types.int 64   "The max channel name length allowed";
        awaylen               = mkSimpleOption types.int 390  "The maximum length of an away message";
        kicklen               = mkSimpleOption types.int 390  "The maximum length of a kick message";
        topiclen              = mkSimpleOption types.int 390  "The maximum length of a channel topic";
        monitor-entries       = mkSimpleOption types.int 100  "The maximum number of monitor entries a client can have";
        whowas-entries        = mkSimpleOption types.int 100  "Whowas entries to store";
        chan-list-modes       = mkSimpleOption types.int 60   "Maximum length of channel lists";
        registration-messages = mkSimpleOption types.int 1024 "Maximum number of messages t o accept during registration";
        multiline = mkSubmoduleOption {
          max-bytes = mkSimpleOption types.int 4096 "Message length limit in bytes for multiline capabilities. Zero means disabled.";
          max-lines = mkSimpleOption types.int 100  "Line limit for limit for multiline capabilities. Zero means no limit.";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable
  {
    environment.etc."ergo.yaml".source = pkgs.writeTextFile {
      name = "ergo.yaml";
      text = builtins.toJSON {
        network.name = cfg.networkName;
        server = cfg.server;
        datastore = cfg.datastore;
        limits = cfg.limits;
      };
    };
  };
}
