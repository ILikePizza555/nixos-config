/* Base nixos system config I use on all my machines. */
{ config, pkgs, ...}:

{
  environment = {
    systemPackages = [
      pkgs.git
      pkgs.ripgrep
      pkgs.tree
      # For encrypting secrets
      pkgs.age
      # Syntax highlighted `cat`
      pkgs.bat 
      pkgs.wget
    ];
  };

  # We have to enable nixFlakes since this is a flake
  nix = {
		extraOptions = ''experimental-features = nix-command flakes'';
  };

  programs = {
    fish = {
      enable = true;
    };

    tmux = {
      enable = true;
    };
  };

	time = {
		timeZone = "America/Los_Angeles";
	};

  users = {
    defaultUserShell = pkgs.fish;
  };
}
