{ config, pkgs, ... }:

{
	imports = [
		../base.nix
		./hardware-configuration.nix
	];

	config = {
		boot = {
			loader = {
				systemd-boot.enable = true;
				efi.canTouchEfiVariables = true;
			};
			kernelPackages = pkgs.linuxPackages_latest;
		};

		environment.systemPackages = [
			pkgs.firefox
			pkgs.networkmanagerapplet
			pkgs.gnome.nautilus
			pkgs.gnome.adwaita-icon-theme
			pkgs.polkit
			pkgs.remmina
		];

		hardware = {
			bluetooth.enable = true;
			opengl = {
				enable = true;
				driSupport32Bit = true;
				extraPackages = [
					pkgs.intel-media-driver
					pkgs.vaapiIntel
					pkgs.vaapiVdpau
					pkgs.libvdpau-va-gl
				];
			};
		};

		location.provider = "geoclue2";

		networking = {
			hostname = "izzy-villian";
			networkmanager.enable = true;
			useDHCP = true;
		};

		nix.extraOptions = ''experimental-features = nix-command flakes'';

		programs = {
			dconf.enable = true;

			gnupg.agent = {
				enable = true;
				enableSSHSupport = true;
			};

			fish.enable = true;
		};

		services = {
			blueman.enable = true;

			gvfs.enable = true;

			pipewire = {
				enable = true;
				alsa = {
					enable = true;
					support32Bit = true;
				};
				pulse.enable = true;
			};

			printing.enable = true;

			redshift = {
				enable = true;
				temperature = {
					day = 5700;
					night = 3500;
				};
			};

			udev = {
				extraRules = ''
					#nRF52840 Dongle in bootloader mode
					ATTRS{idVendor}=="1915", ATTRS{idProduct}=="521f", TAG+="uaccess"

					#nRF52840 Dongle applications
					ATTRS{idVendor}=="2020", TAG+="uaccess"

					#nRF52840 Development Kit
					ATTRS{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1", TAG+="uaccess"
				'';
			};

			udisks2.enable = true;
			upower.enable = true;

			xserver = {
				enable = true;
				layout = "us";
				libinput.enable = true;
				xkbOptions = "eurosign:e";

				displayManager.lightdm = {
					enable = true;
				};

				windowManager.i3 = {
					enable = true;
					extraPackages = [
						pkgs.i3Status
					];
				};
			};
		};

		security = {
			rtkit.enable = true;
		};

		system.stateVersion = "22.05";

		users.users = {
			izzylan = {
				isNormalUser = true;
				description = "Izzy Lancaster's account";
				extraGroups = [ "wheel" "networkmanager" ];
			};
			sonata = {
				isNormalUser = true;
				description = "Sonata's account";
				extraGroups = [ "networkmanager" ];
			};
		};
	};
}
