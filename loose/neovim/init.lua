local nvim_lsp = require'lspconfig'
local rust_tools = require'rust-tools'
local trouble = require'trouble'
local cmp = require'cmp'
local feline = require'feline'
local neogit = require'neogit'

vim.cmd.colorscheme('nightfox')
vim.cmd.syntax('on')

vim.o.autoindent = true
vim.o.smartindent = true
vim.o.expandtab = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2

vim.o.relativenumber = true

neogit.setup({})

feline.setup()

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
