vim.cmd.colorscheme('nightfox')
vim.cmd.syntax('on')

vim.o.autoindent = true
vim.o.smartindent = true
vim.o.expandtab = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2

vim.o.relativenumber = true

-- Keybinds (https://neovim.io/doc/user/api.html#nvim_set_keymap())
-- Telescope keybinds
vim.api.nvim_set_keymap('n', '<Leader>ff', '<cmd>Telescope find_files<cr>', {})
vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', {})
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', {});
vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tdags<cr>', {});
