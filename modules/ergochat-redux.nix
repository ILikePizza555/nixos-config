# Custom module for ergochat since the one in nixpkgs doesn't work properly
{config, lib, pkgs, ...}:
let
  mkSubmoduleFromOptions = options: lib.types.submodule { inherit options; };
  mkSubmoduleOption = options: lib.mkOption { type = mkSubmoduleFromOptions options; default = {}; };
  mkSimpleOption = type: default: description: lib.mkOption { inherit type; inherit default; inherit description; };
  cfg = config.services.ergochat-redux;

  operCapabilitiesEnum = lib.types.enum [
    "kill" 
    "ban"
    "nofakelag"
    "relaymsg"
    "vhosts"
    "sajoin"
    "samode"
    "snomasks"
    "roleplay"
    "rehash"
    "accreg"
    "chanreg"
    "history"
    "defcon"
    "massmessage"
  ];
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

        unix-bind-mode = mkSimpleOption types.int 0511 "The permissions for unix socket listeners";

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

        compatibility = mkSubmoduleOption {
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
          timeout = mkSimpleOption types.str "9s" "timeout for process execution, after which we send a SIGTERM";
          kill-timeout = mkSimpleOption types.str "1s" "how long after the SIGTERM before we follow up with a SIGKILL";
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
        suppress-lusers = mkSimpleOption types.bool false "send all 0's as the LUSERS (user counts) output to non-operators";
      };

      accounts = mkSubmoduleOption {
        authentication-enabled = mkSimpleOption types.bool true "Whether authentication is enabled (can users log into existing accounts?)";

        registration = mkSubmoduleOption {
          enabled = mkSimpleOption types.bool true "can users register new accounts for themselves? if this is false, operators with the `accreg` capability can still create accounts with `/NICKSERV SAREGISTER`";
          allow-before-connect = mkSimpleOption types.bool true "can users use the REGISTER command to register before fully connecting?";

          throttling = mkSubmoduleOption {
            enabled = mkSimpleOption types.bool true "Enable global throttle on new account creation.";
            duration = mkSimpleOption types.str "10m" "Window";
            max-attempts = mkSimpleOption types.int 30 "number of attempts allowed within the window";
          };

          bcrypt-cost = mkSimpleOption types.int 4 "Bcrypt cost to use for account passwords. 4 is the minimum allowed by the bcrypt library";
          verify-timeout = mkSimpleOption types.str "32h" "Length of time a user has to verify their account before it can be re-registered";

          email-verification = mkSubmoduleOption {
            enabled = mkSimpleOption types.bool false "Enable email verification for account registrations";
            sender = mkSimpleOption types.str "admin@my.network" "Sender email address";
            require-tls = mkSimpleOption types.bool true "";
            helo-domain = mkSimpleOption types.str "my.network" "";

            dkim = mkOption {
              type = types.nullOr (mkSubmoduleFromOptions {
                domain = mkOption { type = types.str; };
                selector = mkOption { type = types.str; };
                key-file = mkOption { type = types.path; };
              });
              default = null;
              description = "options to enable DKIM signing of outgoing emails";
            };

            mta = mkOption {
              type = types.nullOr (mkSubmoduleFromOptions {
                server = mkOption { type = types.str; };
                port = mkOption { type = types.int; };
                username = mkOption { type = types.str; };
                password = mkOption { type = types.str; };
              });
              default = null;
              description = "use an MTA/smarthost instead of sending email directly";
            };

            blacklist-regexes = mkOption {
              type = types.listOf types.str;
              default = [];
            };

            timeout = mkSimpleOption types.str "60s" "";

            password-reset = mkSubmoduleOption {
              enabled = mkSimpleOption types.bool false "Enable email-based password reset.";
              cooldown = mkSimpleOption types.str "1h" "Time before allowing resending the email";
              timeout = mkSimpleOption types.str "1d" "Time for which a password reset code is valid";
            };
          };
        };

        login-throttling = mkSubmoduleOption {
          enabled = mkSimpleOption types.bool true "Enable login-throttling";
          duration = mkSimpleOption types.str "1m" "Window";
          max-attempts = mkSimpleOption types.int 3 "Number of attempts allowed within the window";
        };

        skip-server-password = mkSimpleOption types.bool false "Allow a client that fully authenticates with SASL to not send PASS as well.";

        login-via-pass-command = mkSimpleOption types.bool true "Allow older clients that don't support SASL to authenticate with the PASS command";

        require-sasl = mkSubmoduleOption {
          enabled = mkSimpleOption types.bool false "if this is enabled, all clients must authenticate with SASL while connecting";
          exempted = mkSimpleOption (types.listOf types.str) [ "localhost" ] "IPs/CIDRs which are exempted from the account requirement";
        };

        nick-reservation = mkSubmoduleOption {
          enabled = mkSimpleOption types.bool true "Is there any enforcement of reserved nicknames?";
          additional-nick-limit = mkSimpleOption types.int 0 "how many nicknames, in addition to the account name, can be reserved";
          method = mkSimpleOption (types.enum ["strict" "optional"]) "strict" " method describes how nickname reservation is handled";
          allow-custom-enforcement = mkSimpleOption types.bool false "allow users to set their own nickname enforcement status";
          guest-nickname-format = mkSimpleOption types.str "Guest-*" "format for guest nicknames";
          force-guest-format = mkSimpleOption types.bool false "when enabled, forces users not logged into an account to use a nickname matching the guest template";
          force-nick-equals-account = mkSimpleOption types.bool true "when enabled, forces users logged into an account to use the account name as their nickname";
          forbid-anonymous-nick-changes = mkSimpleOption types.bool false "parallel setting to force-nick-equals-account: if true, this forbids anonymous users (i.e., users not logged into an account) to change their nickname after the initial connection is complete";
        };

        multiclient = mkSubmoduleOption {
          enabled = mkSimpleOption types.bool true "when enabled, a new connection that has authenticated with SASL can associate itself with an existing client";
          allowed-by-default = mkSimpleOption types.bool true "if this is disabled, clients have to opt in to bouncer functionality using nickserv or the cap system. if it's enabled, they can opt outvia nickserv ";
          always-on = mkSimpleOption (types.enum ["disabled" "opt-in" "opt-out" "mandatory"]) "opt-in" "whether to allow clients that remain on the server even when they have no active connections";
          auto-away = mkSimpleOption (types.enum ["disabled" "opt-in" "opt-out" "mandatory"]) "opt-in" "whether to mark always-on clients away when they have no active connections";
          always-on-expiration = mkOption {
            type = types.str;
            default = "0"; 
            description = "QUIT always-on clients from the server if they go this long without connecting (use 0 or omit for no expiration)";
            example = "90d";
          };
        };

        vhosts = mkSubmoduleOption {
          enabled = mkSimpleOption types.bool true "Enable the assignement of vhosts via the HostServ service.";
          max-length = mkSimpleOption types.int 64 "Maximum length of a vhost";
          valid-regexp = mkSimpleOption types.str "^[0-9A-Za-z.\\-_/]+$" "Regexp for testing validity of a vhost";
        };

        default-user-modes = mkSimpleOption types.str "+i" "Modes that are set by default when a user connections.";

        auth-script = mkSubmoduleOption {
          enabled = mkSimpleOption types.bool false "Enable a pluggable authentication mechanism via subprocess invocation";
          command = mkSimpleOption types.str "" "Path to script to run for authentication verification.";
          args = mkSimpleOption (types.listOf types.str) [] "constant list of args to pass to the command";
          autocreate = mkSimpleOption types.bool true "Should we automatically create users if the plugin returns success?";
          timeout = mkSimpleOption types.str "9s" "timeout for process execution, after which we send a SIGTERM";
          kill-timeout = mkSimpleOption types.str "1s" "how long after the SIGTERM before we follow up with a SIGKILL";
          max-concurrency = mkSimpleOption types.int 64 "how many scripts are allowed to run at once? 0 for no limit";
        };
      };

      channels = mkSubmoduleOption {
        default-modes = mkSimpleOption types.str "+ntC" "modes that are set when new channels are created";
        max-channels-per-client = mkSimpleOption types.int 100 "if this is true, new channels can only be created by operators with the `chanreg` operator capability";
        operator-only-creation = mkSimpleOption types.bool false "if this is true, new channels can only be created by operators with the `chanreg` operator capability";
        registration = mkSubmoduleOption {
          enabled = mkSimpleOption types.bool true "Can users register new channels?";
          operator-only = mkSimpleOption types.bool false "restrict new channel registrations to operators only";
          max-channels-per-account = mkSimpleOption types.int 15 "how many channels can each account register";
        };
        list-delay = mkSimpleOption types.str "0s" "as a crude countermeasure against spambots, anonymous connections younger than this value will get an empty response to /LIST (a time period of 0 disables)";
        invite-expiration = mkSimpleOption types.str "24h" "INVITE to an invite-only channel expires after this amount of time (0 or omit for no expiration)";
      };

      oper-classes = mkOption {
        type = types.attrsOf (mkSubmoduleFromOptions {
          title = mkOption {
            type = types.str;
            description = "title shown in WHOIS";
          };
          extends = mkOption {
            type = types.nullOr types.str;
            description = "oper class this extends from";
            default = null;
          };
          capabilities = mkOption {
            type = types.listOf operCapabilitiesEnum;
            description = "Capabilities this class has";
          };
        });
        default = {
          chat-moderator = {
            title = "Chat Moderator";
            capabilities = ["kill" "ban" "nofakelag" "relaymsg" "vhosts" "sajoin" "samode" "snomasks" "roleplay"];
          };
          server-admin = {
            title = "Server Admin";
            extends = "chat-moderator";
            capabilities = ["rehash" "accreg" "chanreg" "history" "defcon" "massmessage"];
          };
        };
        description = "an operator has a single \"class\" (defining a privilege level), which can include multiple \"capabilities\" (defining privileged actions they can take).";
      };

      opers = mkOption {
        type = types.attrsOf (mkSubmoduleFromOptions {
          class = mkOption { 
            type = types.str;
            description = "Which capabilities this oper has access to";
          };
          hidden = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to show to the operator status to unprivileged users in WHO and WHOIS responses";
          };
          whois-line = mkOption {
            type = types.nullOr types.str;
            description = "custom whois line (if `hidden` is enabled, visible only to other operators)";
            exmaple = "staff";
            default = null;
          };
          modes = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "modes to auto-set upon opering-up";
            example = "+is acdjknoqtuxv";
          };
          passwordHash = mkSimpleOption (types.nullOr types.str) null "Ergo password hash generated by ergo genpasswd.";
          # TODO: Add more options for passwords
          certfp = mkOption (types.nullOr types.str) null "if a SHA-256 certificate fingerprint is configured here, then it will be required to /OPER ";
          auto = mkOption types.bool false "if 'auto' is set (and no password hash is set), operator permissions will be granted automatically as soon as you connect with the right fingerprint";
        });
        default = {};
      };

      logging = mkOption {
        type = types.listOf (mkSubmoduleFromOptions {
          level = mkOption {
            type = types.str;
            description = "Sets the logging level of the logger.";
            example = "info";
          };
          method = mkOption {
            type = types.str;
            description = "Where the logger should log";
            example = "stderr";
          };
          type = mkOption {
            type = types.str;
            example = "* -userinput -useroutput";
          };
        });
        default = [
          {
            level = "info";
            method = "stderr";
            type = "* -userinput -useroutput";
          }
        ];
      };

      debug = mkSubmoduleOption {
        recover-from-errors = mkSimpleOption types.bool true "when enabled, Ergo will attempt to recover from certain kinds of client-triggered runtime errors that would normally crash the server. this makes the server more resilient to DoS, but could result in incorrect behavior.";

        pprof-listener = mkOption {
          type = types.str;
          default = "";
          example = "localhost:6060";
          description = "optionally expose a pprof http endpoint: https://golang.org/pkg/net/http/pprof/ it is strongly recommended that you don't expose this on a public interface if you need to access it remotely, you can use an SSH tunnel. Leave blank to disable.";
        };
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

      languages = mkSubmoduleOption {
        enabled = mkSimpleOption types.bool true "Whether to load languages";
        default = mkSimpleOption types.str "en" "Default language for new clients";
        path = mkSimpleOption types.str "languages" "Which directory contains language files";
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

      fakelag = mkSubmoduleOption {
        enabled = mkSimpleOption types.bool true "Whether to enforce fakelag";
        window = mkSimpleOption types.str "1s" "Time unit for counting command rates";
        burst-limit = mkSimpleOption types.int 5 "Clients can send  this many commands without fakelag being imposed";
        messages-per-window = mkSimpleOption types.int 2 "once clients have exceeded their burst allowance, they can send only this many commands per `window`";
        cooldown = mkSimpleOption types.str "2s" "client status resets to the default state if they go this long without sending any commands";
        command-budgets = mkOption {
          type = types.attrsOf types.int;
          default = {
            CHATHISTORY = 16;
            MARKREAD = 16;
            MONITOR = 1;
            WHO = 1;
          };
          description = "exempt a certain number of command invocations per session from fakelag. this is to speed up \"resynchronization\" of client state during reattach";
        };
      };

      roleplay = mkSubmoduleOption {
        enabled = mkSimpleOption types.bool false "Whether to enable roleplay commands";
        require-oper = mkSimpleOption types.bool false "Whether to require the roleplay oper capability to send roleplay messages";
        require-chanops = mkSimpleOption types.bool false "Whether to require channel operator permissions to send roleplay messages";
        add-suffix = mkSimpleOption types.bool true "Whether to add the real nickname in parentheses to the end of every roleplay message";
      };

      extjwt = mkOption {
        type = types.nullOr (mkSubmoduleFromOptions {
          expiration = mkSimpleOption types.str "45s" "Expiration time for the token";
          secret = mkSimpleOption (types.nullOr types.str) null "Configure token to be signed with an HMAC and a symmetric secret";
          rsa-private-key-file = mkSimpleOption (types.nullOr types.str) null "Configure token to be signed with RSA private key";
          services = mkOption {
            type = types.attrsOf (mkSubmoduleFromOptions {
              expiration = mkOption { type = type.str; };
              secret = mkSimpleOption { type = types.nullOr types.str; };
              rsa-private-key-file = mkSimpleOption { type = types.nullOr types.str; };
            });
            default = {};
          };
        });
        default = null;
      };

      history = mkSubmoduleOption {
        enabled = mkSimpleOption types.bool true "Whether to enable chat history?";
        channel-length = mkSimpleOption types.int 2048 "The number of channel-specific events (messages, joins, parts) should be tracked per channel";
        client-length = mkSimpleOption types.int 256 "The number of direct messages and notices to be tracked per user";
        autoresize-window = mkSimpleOption types.str "3d" "The amount of time messages should be preserved.";
        autoreplay-on-join = mkSimpleOption types.int 0 "The number of messages to automatically play back on channel join (0 to disable)";
        chathistory-maxmessages = mkSimpleOption types.int 1000 "The maximum number of CHATHISTORY messages that can be requested at once. (0 disables support for CHATHISTORY)";
        znc-maxmessages = mkSimpleOption types.int 2048 "Maximum number of messages that can be replayed at once during znc emulation";
        restrictions = mkSubmoduleOption {
          expire-time = mkSimpleOption types.str "1w" "if this is set, messages older than this cannot be retrieved by anyone (and will eventually be deleted from persistent storage, if that's enabled)";
          query-cutoff = mkSimpleOption (types.enum ["none" "registration-time" "join-time"]) "none" "this restricts access to channel history (it can be overridden by channel owners)";
          grace-period = mkSimpleOption types.str "1h" "if query-cutoff is set to 'registration-time', this allows retrieval of messages that are up to 'grace-period' older than the above cutoff. if you use 'registration-time', this is recommended to allow logged-out users to query history after disconnections.";
        };
        persistent = let
          optEnum = types.enum ["disabled" "opt-in" "opt-out" "mandatory"];
        in mkSubmoduleOption {
          enabled = mkSimpleOption types.bool false "Whether to enable the storage of history messages in a persistend database";
          unregistered-channels = mkSimpleOption types.bool false "Whether to store unregistered channel messages in the persistent database";
          registered-channels = mkSimpleOption optEnum "opt-out" "Default history storage setting for registered channels";
          direct-messages = mkSimpleOption optEnum "opt-out" "Default history storage setting for direct messages";
        };
        retention = mkSubmoduleOption {
          allow-individual-delete = mkSimpleOption types.bool false "Whether to allow users to delete their own messages from history";
          enable-account-indexing = mkSimpleOption types.bool false "if persistent history is enabled, create additional index tables, allowing deletion of JSON export of an account's messages. this may be needed for compliance with data privacy regulations.";
        };
        tagmsg-storage = mkSubmoduleOption {
          default = mkSimpleOption types.bool false "Whether TAGMSG should be stored by default";
          whitelist = mkSimpleOption (types.listOf types.str) ["+draft/react" "+react"] "If default is false, store TAGMSG containing any of these tags";
          blacklist = mkSimpleOption (types.listOf types.str) [] "If default is true, don't store TAGMSG containing any of these tags";
        };
      };

      openFilesLimit = mkOption {
        type = types.int;
        default = 1024;
        description = "Maximum number of open files. Limits the clients and server connections.";
      };
    };
  };

  config = let
    acmeHosts = let
      hostList = lib.mapAttrsToList (listenerName: listenerCfg: listenerCfg.useACMEHost) cfg.server.listeners;
      filteredHostList = builtins.filter (x: x != null) hostList;
      in
      lib.unique filteredHostList;

    applyACMEToListener = listenerName: listenerCfg:
      builtins.removeAttrs listenerCfg ["useACMEHost"] //
      (if listenerCfg.useACMEHost != null && builtins.stringLength listenerCfg.useACMEHost != 0 then
        {
          tls = {
            cert = config.security.acme.certs.${listenerCfg.useACMEHost}.directory + "/cert.pem";
            key = config.security.acme.certs.${listenerCfg.useACMEHost}.directory + "/key.pem";
          };
        }
      else {});


    fixServerCfg = serverCfg: (builtins.removeAttrs serverCfg ["websocketsAllowedOrigins"]) // {
      websockets = { allowed-origins = serverCfg.websocketsAllowedOrigins; };
      listeners = builtins.mapAttrs applyACMEToListener serverCfg.listeners;
    };

    enableMysql = cfg.datastore.mysql.enabled && cfg.datastore.mysql.ensureDB;

    fixDatastoreCfg = datastoreCfg: datastoreCfg // {
      mysql = let
        removeNames = ["ensureDB"] ++ (if enableMysql then ["password"] else []);
        updates = if enableMysql then {
          socket-path = "/run/mysqld/mysqld.sock";
        } else {};
      in
      (builtins.removeAttrs datastoreCfg.mysql removeNames) // updates; 
    };
  in
  lib.mkIf cfg.enable {
    environment.etc."ergo.yaml".source = pkgs.writeTextFile {
      name = "ergo.yaml";
      text = builtins.toJSON {
        network.name = cfg.networkName;
        server = fixServerCfg cfg.server;
        accounts = cfg.accounts;
        channels = cfg.channels;
        oper-classes = cfg.oper-classes;
        opers = cfg.opers;
        logging = cfg.logging;
        debug = cfg.debug;
        lock-file = "ircd.lock";
        datastore = fixDatastoreCfg cfg.datastore;
        languages = cfg.languages;
        limits = cfg.limits;
        fakelag = cfg.fakelag;
        roleplay = cfg.roleplay;
        extjwt = cfg.extjwt;
        history = cfg.history;
      };
    };

    services.mysql = if enableMysql then {
      enable = true;
      ensureDatabases = [ cfg.datastore.mysql.history-database ];
      ensureUsers = [
        {
          name = cfg.datastore.mysql.user;
          ensurePermissions = {
            "${cfg.datastore.mysql.history-database}.*" = "ALL PRIVILEGES"; 
          };
        }
      ];
    } else {};

    systemd.services.ergochat-redux = {
      description = "Ergo IRC daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.coreutils}/bin/mkdir -p languages && ${pkgs.ergochat}/bin/ergo run --conf /etc/ergo.yaml";
        ExecReload = "${pkgs.util-linux}/bin/kill -HUP $MAINPID";
        DynamicUser = true;
        StateDirectory = "ergo";
        LimitNOFILE = toString cfg.openFilesLimit;
        SupplementaryGroups = map (ACMEHost: config.security.acme.certs.${ACMEHost}.group) acmeHosts;
      };
    };
  };
}
