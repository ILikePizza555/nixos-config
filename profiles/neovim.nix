/*
* This module contains configuration for a system-level neovim.
* This is a basic config due to how the nixpkgs neovim module works.
* It's geared towards editing nix files for bootstrapping a system (or editing stuff in root).
*/

{pkgs, ...}:
{
  environment = {
    systemPackages = [
      # Required for telescope
      pkgs.ripgrep
    ];
  };

  programs = {
		neovim = {
			enable = true;
			defaultEditor = true;
			configure = {
				customRC = ''
          set autoindent smartindent noexpandtab tabstop=2 shiftwidth=2
					set relativenumber
					syntax on

          nnoremap <leader>ff <cmd>Telescope find_files<cr>
          nnoremap <leader>fg <cmd>Telescope live_grep<cr>
          nnoremap <leader>fb <cmd>Telescope buffers<cr>
          nnoremap <leader>fh <cmd>Telescope help_tdags<cr>
				'';
				packages.myVimPackage = with pkgs.vimPlugins; {
					start = [
            nightfox-nvim
						vim-nix
						indent-blankline-nvim
						plenary-nvim
					  telescope-nvim
            nvim-web-devicons
            barbar-nvim
					];
				};
			};
    };
  };
}
