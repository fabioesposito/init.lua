-- lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- ------------
-- Plugin install
-- ------------
require("lazy").setup({
	{ "nvim-lua/plenary.nvim" },
	{ 'nvim-tree/nvim-web-devicons' },

	-- color theme
	{
		"craftzdog/solarized-osaka.nvim",
		lazy = false,
		priority = 1000,
		config = function() vim.cmd.colorscheme 'solarized-osaka' end,
		opts = {},
	},

	-- file manager
	{ "stevearc/oil.nvim",                   opts = { default_file_explorer = false } },

	-- collection of utilities
	{ 'echasnovski/mini.nvim',               version = '*' },

	-- git stuff
	{ "kdheepak/lazygit.nvim", },
	{ 'lewis6991/gitsigns.nvim' },
	{ 'tpope/vim-fugitive' },
	{ 'tpope/vim-rhubarb' },

	-- vertical guide
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl",                            opts = {} },

	-- colorize tags like TODO: FIXME: NOTE:
	{ "folke/todo-comments.nvim",            opts = {} },

	-- command palette
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {}
	},

	-- telescope
	{ 'nvim-telescope/telescope.nvim',    tag = '0.1.5', },

	-- LSP plugins
	{ 'williamboman/mason.nvim' },
	{ 'williamboman/mason-lspconfig.nvim' },
	{ 'VonHeikemen/lsp-zero.nvim',        branch = 'v3.x' },
	{ 'neovim/nvim-lspconfig' },
	{ 'hrsh7th/cmp-nvim-lsp' },
	{ 'hrsh7th/cmp-path' },
	{ 'hrsh7th/cmp-buffer' },
	{ 'hrsh7th/nvim-cmp' },
	{ 'L3MON4D3/LuaSnip' },
	{
		'nvim-treesitter/nvim-treesitter',
		dependencies = {
			'nvim-treesitter/nvim-treesitter-textobjects',
		},
		build = ':TSUpdate',
	},

	-- golang extra functionalities
	{
		"ray-x/go.nvim",
		dependencies = { -- optional packages
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("go").setup()
		end,
		event = { "CmdlineEnter" },
		ft = { "go", 'gomod' },
		build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
	},

	-- llm
	{
		"jackMort/ChatGPT.nvim",
		event = "VeryLazy",
		config = function()
			require("chatgpt").setup()
		end,
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim"
		}
	},
})

-- ------------
-- Plugin config
-- ------------
require('mini.basics').setup()
require('mini.tabline').setup()
require('mini.statusline').setup()
require('mini.pairs').setup()
require('mini.surround').setup()
require('mini.comment').setup()
require('mini.cursorword').setup()
require('mini.fuzzy').setup()

require('which-key').register({
	['<leader>h'] = { 'Git [H]unk' },
	['<leader>s'] = { '[S]earch' },
	['<leader>b'] = { '[B]uffers' },
	['<leader>g'] = { 'LSP' },
}, { mode = 'n' })

require('gitsigns').setup {
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map('n', ']c', function()
			if vim.wo.diff then return ']c' end
			vim.schedule(function() gs.next_hunk() end)
			return '<Ignore>'
		end, { expr = true })

		map('n', '[c', function()
			if vim.wo.diff then return '[c' end
			vim.schedule(function() gs.prev_hunk() end)
			return '<Ignore>'
		end, { expr = true })

		-- Actions
		map('n', '<leader>hd', gs.diffthis, { desc = "Diff" })
		map('n', '<leader>hp', gs.preview_hunk)
		map('n', '<leader>hs', gs.stage_hunk, { desc = "Stage hunk" })
		map('n', '<leader>hS', gs.stage_buffer, { desc = "Stage buffer" })
		map('n', '<leader>hr', gs.reset_hunk, { desc = "Reset hunk" })
		map('n', '<leader>hR', gs.reset_buffer, { desc = "Reset buffer" })
		map('n', '<leader>hu', gs.undo_stage_hunk, { desc = "Undo stage hunk" })
	end
}

require('nvim-treesitter.configs').setup {
	-- Add languages to be installed here that you want installed for treesitter
	ensure_installed = { 'go', 'lua', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

	-- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
	auto_install = true,

	textobjects = {
		swap = {
			enable = true,
			swap_next = {
				["<leader>a"] = "@parameter.inner",
			},
			swap_previous = {
				["<leader>A"] = "@parameter.inner",
			},
		},
	},
}

local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(client, bufnr)
	lsp_zero.buffer_autoformat()

	-- see :help lsp-zero-keybindings
	-- to learn the available actions
	lsp_zero.default_keymaps({
		buffer = bufnr,
		preserve_mappings = false
	})
end)
lsp_zero.setup_servers({ 'lua_ls', 'rust_analyzer', 'gopls', 'html', 'htmx', 'tsserver' })

local cmp = require('cmp')
cmp.setup({
	sources = {
		{ name = 'path' },
		{ name = 'nvim_lsp' },
		{ name = 'nvim_lua' },
		{ name = 'luasnip', keyword_length = 2 },
		{ name = 'buffer',  keyword_length = 3 },
	},
	formatting = lsp_zero.cmp_format(),
})

-- see :help lsp-zero-guide:integrate-with-mason-nvim
-- to learn how to use mason.nvim with lsp-zero
require('mason').setup({})
require('mason-lspconfig').setup({
	handlers = { lsp_zero.default_setup },
})

-- ------------
-- vim configs
-- ------------
-- fix tabs
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.smartindent = true

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.scrolloff = 8

-- ------------
-- keybindings
-- ------------
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- move select text up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")

-- pgup/down with cursor in the middle
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- keep cursor in the middle when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = '*',
})

vim.keymap.set('n', '<leader>e', ':Oil --float<cr>', { desc = '[E]xplorer' })
vim.keymap.set('n', '<leader>bl', require('telescope.builtin').buffers, { desc = 'Buffer [l]ist' })
vim.keymap.set('n', '<leader>bc', ':bdelete<cr>', { desc = '[C]lose buffer' })
vim.keymap.set('n', '<leader>bn', ':bnext<cr>', { desc = '[N]ext buffer' })
vim.keymap.set('n', '<leader>bp', ':bprevious<cr>', { desc = '[P]revious buffer' })

local function telescope_live_grep_open_files()
	require('telescope.builtin').live_grep {
		grep_open_files = true,
		prompt_title = 'Live Grep in Open Files',
	}
end

vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').git_files, { desc = '[S]earch [G]it Files' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').live_grep, { desc = '[S]earch by G[r]ep' })
