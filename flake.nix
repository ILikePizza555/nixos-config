{
	inputs = {
		nixpkgs.url = github:NixOS/nixpkgs;
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager }: {
    nixosConfigurations."vm-goth-pinkie-pie" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [
        ./hosts/goth-pinkie-pie
        ./programs/neovim.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.users.izzylan = {config, lib, pkgs, ...}:
          {
            home = {
              username = "izzylan";
              homeDirectory = "/home/izzylan";
              stateVersion = "22.05";
            };

            programs = {
              git = {
                enable = true;
                userName = "izzylan";
                userEmail = "avrisaac555@gmail.com";
              };

              home-manager = {
                enable = true;
              };
            };

            systemd.user.services = {
              # vscode-server
              # TODO: Refactor into it's own module
              auto-fix-vscode-server = {
                Unit = {
                  Description = "Automatically fix the VS Code server used by the remote SSH extension";
                };

                Service = {
                  Restart = "always";
                  RestartSec = 0;
                  ExecStart = "${pkgs.writeShellScript "auto-fix-vscode-server.sh" ''
                    set -euo pipefail
                    PATH=${lib.makeBinPath (with pkgs; [ coreutils findutils inotify-tools ])}
                    bin_dir=~/.vscode-server/bin
                    # Fix any existing symlinks before we enter the inotify loop.
                    if [[ -e $bin_dir ]]; then
                      find "$bin_dir" -mindepth 2 -maxdepth 2 -name node -exec ln -sfT ${pkgs.nodejs-16_x}/bin/node {} \;
                      find "$bin_dir" -path '*/@vscode/ripgrep/bin/rg' -exec ln -sfT ${pkgs.ripgrep}/bin/rg {} \;
                    else
                      mkdir -p "$bin_dir"
                    fi
                    while IFS=: read -r bin_dir event; do
                      # A new version of the VS Code Server is being created.
                      if [[ $event == 'CREATE,ISDIR' ]]; then
                        # Create a trigger to know when their node is being created and replace it for our symlink.
                        touch "$bin_dir/node"
                        inotifywait -qq -e DELETE_SELF "$bin_dir/node"
                        ln -sfT ${pkgs.nodejs-16_x}/bin/node "$bin_dir/node"
                        ln -sfT ${pkgs.ripgrep}/bin/rg "$bin_dir/node_modules/@vscode/ripgrep/bin/rg"
                      # The monitored directory is deleted, e.g. when "Uninstall VS Code Server from Host" has been run.
                      elif [[ $event == DELETE_SELF ]]; then
                        # See the comments above Restart in the service config.
                        exit 0
                      fi
                    done < <(inotifywait -q -m -e CREATE,ISDIR -e DELETE_SELF --format '%w%f:%e' "$bin_dir")
                  ''}";
                };

                Install = {
                  WantedBy = [ "default.target" ];
                };
              };
            };
          };
        }
      ];
    };
  };
}
