/*
* This module contains configuration for a system-level neovim.
* Todo: Refactor this into a system module. Some points to consider:
*   - We can reuse `wrapNeovimUnstable`, so long as we pass `wrapRc = false` to prevent it from create an init.vim
*		- `makeNeovimConfig` lets you specify per-plugin configuration (by passing in an attrset with the `config` option set), which would get built into the init.vim file. Perhaps the module should have a similar functionality for lua?
		- Still need to figure out what `extraPythonPackages` and `extraLuaPackages` do in https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/neovim/utils.nix
	Important sources (which I used to help me construct this file):
	- https://neovim.io/doc/user/starting.html#initialization
	- https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/neovim/utils.nix
	- https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/neovim/wrapper.nix
*/

{pkgs, lib, ...}:

let
  neovimInitFile = ./../loose/neovim/init.lua;

  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    withPython3 = true;
    withNodeJs = true;
		# plugins can be a listof attrset with {plugin: package, config: string, options: bool} or just a list of packages.
    plugins = with pkgs.vimPlugins; [
      nightfox-nvim
      vim-nix
      indent-blankline-nvim
      plenary-nvim
      telescope-nvim
      neogit
      feline-nvim
      nvim-web-devicons
      barbar-nvim
      nvim-lspconfig
      rust-tools-nvim
      trouble-nvim
      luasnip
      nvim-cmp
      cmp-nvim-lsp
      cmp_luasnip
      cmp-buffer
    ];
  };

  neovimPackage = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (neovimConfig // {
    wrapperArgs = neovimConfig.wrapperArgs ++ [ "--add-flags" "-u ${neovimInitFile}"];
    # Disable the auto generation of init.vim, because we're using a lua init
    wrapRc = false;
  }); 
in {
  environment = {
    systemPackages = [
        # Required for telescope
        pkgs.ripgrep
        pkgs.fd

        neovimPackage
      ];
    variables.EDITOR = lib.mkOverride 900 "nvim";
  };
}
