{ config, lib, pkgs, modulesPath, ... }:

{
	imports =
		[ (modulesPath + "/installer/scan/not-detected.nix")
		];
	
	boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
	boot.initrd.kernelModules = [ ];
	boot.kernelModules = [ "kvm-intel" ];
	boot.extraModulePackages = [ ];

	fileSystems."/" =
		{ device = "/dev/disk/by-uuid/e2632c67-9d37-4287-a9f8-849b934621da";
			fsType = "ext4";
		};

	fileSystems."/boot" =
		{ device = "/dev/disl/by-uuid/162C-5199";
			fsType = "vfat";
		};

	swapDevices = [ ];

	powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
