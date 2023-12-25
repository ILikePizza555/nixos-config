# The dawn breaks the night's silent shroud, as Eos ascends the sky.
# Her amber light casts  over the heavens, earth, and the vast sea's edge.
# With delicate grace, she strokes the sky, crafting the morn's vibrant hue.
# Her song, a dulcet whisper, calls to the creatures under the azure:
# "Awaken friends, for I user in the day once more. Cast aside yesternight's shadows and begin anew." 
# ---
# eos is the nixos installation I run on WSL.
# It is primarily used to boostrap and work on projects.

{ conifg, pkgs, nixos-wsl, ... }:

{
	imports = [
		../base.nix
		nixos-wsl.nixosModules.wsl
	];

	wsl = {
		enable = true;
		defaultUser = "prophet";
		wslConf.network.hostname = "eos";
	};

	system.stateVersion = "23.11";
}