/* Base nixos system config I use on all my machines. */
{ config, pkgs, ...}:

{
	environment = {
		systemPackages = with pkgs; [
			git
			ripgrep
			tree
			# For encrypting secrets
			age
			# Syntax highlighted `cat`
			bat 
			# Modern replacement for `ls`
			eza
			# Modern replacement for `find`
			fd
			wget
			# Terminal-based file manager
			nnn
			fzf
			fishPlugins.fzf-fish
			fishPlugins.forgit
		];
	};

	# We have to enable nixFlakes since this is a flake
	nix = {
		extraOptions = ''experimental-features = nix-command flakes'';
	};

	environment.shellAliases = {
		l = "eza -aal";
		ll = "eza -l";
		ls = "eza";
		cat = "bat";
		find = "fd";
	};

	programs = {
		fish.enable = true;
		thefuck.enable = true;
		tmux.enable = true;
	};

	time = {
		timeZone = "America/Los_Angeles";
	};

	users = {
		defaultUserShell = pkgs.fish;
	};
}
