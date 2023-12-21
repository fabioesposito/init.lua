vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

	-- nerdfonts, icons and so on...
	{ 'nvim-tree/nvim-web-devicons' },

	-- rose-pine theme
	{
		"rose-pine/neovim",
		config = function()
			vim.cmd.colorscheme 'rose-pine-moon'
		end,
	},

	-- file manager
	{ "stevearc/oil.nvim",          opts = {} },

	-- collection of utilities
	{
		'echasnovski/mini.nvim',
		version = '*'
	},

	-- git stuff
	{
		"kdheepak/lazygit.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{ 'lewis6991/gitsigns.nvim' },
	{ 'tpope/vim-fugitive' },
	{ 'tpope/vim-rhubarb' },

	-- vertical guide
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {}
	},

	-- colorize TODO: FIXME: NOTE: tags
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {}
	},

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
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.5',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},

	-- lastly the LSP plugins
	{ 'williamboman/mason.nvim' },
	{ 'williamboman/mason-lspconfig.nvim' },
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x'
	},
	{ 'neovim/nvim-lspconfig' },
	{ 'hrsh7th/cmp-nvim-lsp' },
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

	-- local LLM using ollama
	{
		"David-Kunz/gen.nvim",
		opts = {
			model = "mistral:7b", -- The default model to use.
			-- model = "phi", -- The default model to use.
			display_mode = "float", -- The display mode. Can be "float" or "split".
			show_prompt = false, -- Shows the Prompt submitted to Ollama.
			show_model = false, -- Displays which model you are using at the beginning of your chat session.
			no_auto_close = false, -- Never closes the window automatically.
			init = function(options) pcall(io.popen, "ollama serve > /dev/null 2>&1 &") end,
			-- Function to initialize Ollama
			command = "curl --silent --no-buffer -X POST http://localhost:11434/api/generate -d $body",
			-- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
			-- This can also be a lua function returning a command string, with options as the input parameter.
			-- The executed command must return a JSON object with { response, context }
			-- (context property is optional).
			list_models = '<omitted lua function>', -- Retrieves a list of model names
			debug = false                  -- Prints errors and the command which is run.
		},
	},

})

-- ------------
-- Plugin config
-- ------------
-- require('mini.basics').setup()
require('mini.tabline').setup()
require('mini.statusline').setup()
require('mini.pairs').setup()
require('mini.surround').setup()
require('mini.comment').setup()
require('mini.cursorword').setup()
require('mini.fuzzy').setup()

local animate = require('mini.animate')
animate.setup({
	cursor = {
		-- Animate for 200 milliseconds with linear easing
		timing = animate.gen_timing.linear({ duration = 200, unit = 'total' }),

		-- Animate with shortest line for any cursor move
		path = animate.gen_path.line({
			predicate = function() return true end,
		}),
	}
})


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
		map('n', '<leader>hs', gs.stage_hunk, { desc = "Stage hunk" })
		map('n', '<leader>hr', gs.reset_hunk, { desc = "Reset hunk" })
		map('n', '<leader>hS', gs.stage_buffer, { desc = "Stage buffer" })
		map('n', '<leader>hu', gs.undo_stage_hunk, { desc = "Undo stage hunk" })
		map('n', '<leader>hR', gs.reset_buffer, { desc = "Reset buffer" })
		map('n', '<leader>hd', gs.diffthis, { desc = "Diff" })
	end
}

require('which-key').register({
	['<leader>h'] = { 'Git [H]unk' },
	['<leader>s'] = { '[S]earch' },
	['<leader>b'] = { '[B]uffers' },
	['<leader>g'] = { '[L]SP' },
}, { mode = 'n' })
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(client, bufnr)
	lsp_zero.buffer_autoformat()

	-- see :help lsp-zero-keybindings
	-- to learn the available actions
	-- lsp_zero.default_keymaps({ buffer = bufnr })
	vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', { buffer = bufnr })
	vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<cr>', { buffer = bufnr })
	vim.keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<cr>', { buffer = bufnr })
	vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
	vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
end)

cmp.setup({
	sources = {
		{ name = 'path' },
		{ name = 'nvim_lsp' },
		-- { name = 'nvim_lua' },
	},
	formatting = lsp_zero.cmp_format(),
	mapping = cmp.mapping.preset.insert({
		['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
		['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
		['<C-y>'] = cmp.mapping.confirm({ select = true }),
		['<C-Space>'] = cmp.mapping.complete(),
	}),
})

-- see :help lsp-zero-guide:integrate-with-mason-nvim
-- to learn how to use mason.nvim with lsp-zero
require('mason').setup({})
require('mason-lspconfig').setup({
	handlers = {
		lsp_zero.default_setup,
	}
})

-- ------------
-- vim configs
-- ------------

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.smartindent = true

vim.o.scrolloff = 8

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

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

vim.keymap.set('n', '<leader>f', ':Oil --float<cr>', { desc = '[F]ile manager' })
vim.keymap.set('n', '<leader>bl', require('telescope.builtin').buffers, { desc = 'Buffer [l]ist' })
vim.keymap.set('n', '<leader>bc', ':bdelete<cr>', { desc = '[C]lose buffer' })
vim.keymap.set('n', '<leader>bn', ':bnext<cr>', { desc = '[N]ext buffer' })
vim.keymap.set('n', '<leader>bp', ':bprevious<cr>', { desc = '[P]revious buffer' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').git_files, { desc = '[S]earch [G]it Files' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').live_grep, { desc = '[S]earch by G[r]ep' })
