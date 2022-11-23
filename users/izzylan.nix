{config, lib, pkgs, ...}:
{
  imports = [
    ../modules/auto-fix-vscode-server.nix
  ];

  home = {
    username = "izzylan";
    homeDirectory = "/home/izzylan";
    stateVersion = "22.05";
  };

  programs = {
    direnv = {
      enable = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      userName = "izzylan";
      userEmail = "avrisaac555@gmail.com";
    };

    home-manager = {
      enable = true;
    };
  };
}
