local nvim_lsp = require'lspconfig'
local rust_tools = require'rust-tools'
local trouble = require'trouble'
local cmp = require'cmp'
local neogit = require'neogit'

vim.cmd.syntax('on')

vim.o.autoindent = true
vim.o.smartindent = true
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2

vim.o.relativenumber = true

-- Not quite part of indent-blankline, but closely related
vim.o.list = true
vim.opt.listchars:append "lead:⋅"
vim.opt.listchars:append "eol:↴"

neogit.setup({})

require('lualine').setup()

-- indent-blankline setp
-- https://github.com/lukas-reineke/indent-blankline.nvim
require("indent_blankline").setup({
	show_end_of_line = true
})

-- Onedark config
require('onedark').setup({
	style = 'warmer',
	toggle_style_key = '<Leader>ts'
})
vim.cmd.colorscheme('onedark')

-- Keybinds (https://neovim.io/doc/user/api.html#nvim_set_keymap())
-- Telescope keybinds
vim.api.nvim_set_keymap('n', '<Leader>ff', '<cmd>Telescope find_files<cr>', {})
vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', {})
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', {});
vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tdags<cr>', {})

-- LSP client diagnostics keybinds
vim.keymap.set('n', '<space>e',	vim.diagnostic.open_float,	{ noremap = true, silent = true })
vim.keymap.set('n', '[d',				vim.diagnostic.goto_prev,		{ noremap = true, silent = true })
vim.keymap.set('n', ']d',				vim.diagnostic.goto_next,		{ noremap = true, silent = true })
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist,	{ noremap = true, silent = true })

local rust_lsp_on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap=true, silent=true, buffer=bufnr }
	vim.keymap.set('n', 'gD',					vim.lsp.buf.declaration, bufopts)
	vim.keymap.set('n', 'gd',					vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', 'K',					vim.lsp.buf.hover, bufopts)
	vim.keymap.set('n', 'gi',					vim.lsp.buf.implementation, bufopts)
	vim.keymap.set('n', '<C-k>',			vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set('n', '<space>wa',	vim.lsp.buf.add_workspace_folder, bufopts)
	vim.keymap.set('n', '<space>wr',	vim.lsp.buf.remove_workspace_folder, bufopts)
	vim.keymap.set('n', '<space>wl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)
	vim.keymap.set('n', '<space>D',		vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set('n', '<space>rn',	vim.lsp.buf.rename, bufopts)
	vim.keymap.set('n', '<space>ca',	vim.lsp.buf.code_action, bufopts)
	vim.keymap.set('n', 'gr',					vim.lsp.buf.references, bufopts)
	vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- LSP Configuration
rust_tools.setup({
	server = {
		on_attach = rust_lsp_on_attach
	}
})


trouble.setup()

cmp.setup({
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-n>'] = cmp.mapping.select_next_item(),
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	}, {
		{ name = 'buffer' }
	})
})

-- Discord rich presence
require("presence"):setup({
	auto_update					= true,
	log_level						= "info",
	editing_text				= "Editing %s",								-- Format string rendered when an editable file is loaded in the buffer (either string or function(filename: string): string)
	file_explorer_text	= "Browsing %s",							-- Format string rendered when browsing a file explorer (either string or function(file_explorer_name: string): string)
	git_commit_text			= "Committing changes",				-- Format string rendered when committing changes in git (either string or function(filename: string): string)
	plugin_manager_text	= "Managing plugins",					-- Format string rendered when managing plugins (either string or function(plugin_manager_name: string): string)
	reading_text				= "Reading %s",								-- Format string rendered when a read-only or unmodifiable file is loaded in the buffer (either string or function(filename: string): string)
	workspace_text			= "Working on %s",						-- Format string rendered when in a git repository (either string or function(project_name: string|nil, filename: string): string)
	line_number_text		= "Line %s out of %s",				-- Format string rendered when `enable_line_number` is set to true (either string or function(line_number: number, line_count: number): string)
})
