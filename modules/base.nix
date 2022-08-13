/* Base nixos system config I use on all my machines. */
{ config, pkgs, ...}:

{
  environment = {
    systemPackages = [
      pkgs.git
      pkgs.ripgrep
    ];
  };

  # We have to enable nixFlakes since this is a flake
  nix = {
    package = pkgs.nixFlakes;
		extraOptions = ''experimental-features = nix-command flakes'';
  };

  programs = {
    fish = {
      enable = true;
    };
  };

	time = {
		timeZone = "America/Los_Angeles";
	};
}
