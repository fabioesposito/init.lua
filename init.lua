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
require("lazy").setup({
	{ "nvim-lua/plenary.nvim" },
	{ 'nvim-tree/nvim-web-devicons' },
	{ 'MunifTanjim/nui.nvim' },
	{ "folke/noice.nvim",              event = "VeryLazy", },

	-- colorscheme
	{ "scottmckendry/cyberdream.nvim", },

	-- file manager
	{
		"stevearc/oil.nvim",
		opts = { default_file_explorer = false },
		event = 'VeryLazy'
	},

	-- collection of utilities
	{ 'echasnovski/mini.nvim',  version = '*' },
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},

	-- git stuff
	{ "kdheepak/lazygit.nvim",  event = 'VeryLazy' },
	{ 'lewis6991/gitsigns.nvim' },
	{ 'tpope/vim-fugitive' },
	{ 'tpope/vim-rhubarb' },
	{
		'pwntester/octo.nvim',
		config = function() require "octo".setup() end,
		event = 'VeryLazy'
	},

	-- vertical guide
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

	-- colorize tags like TODO: FIXME: NOTE:
	{
		"folke/todo-comments.nvim",
		opts = {}
	},

	{ -- command helper
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {}
	},
	{
		'rmagatti/auto-session',
		config = function()
			require("auto-session").setup {
				log_level = "error",
				auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			}
		end
	},
	-- telescope
	{
		'nvim-telescope/telescope-fzf-native.nvim',
		build =
		'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
	},
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.6',
		dependencies = {
			"nvim-telescope/telescope-live-grep-args.nvim",
		},
		config = function()
			require("telescope").load_extension("live_grep_args")
		end,
	},

	-- LSP plugins
	{ 'williamboman/mason.nvim' },
	{ 'williamboman/mason-lspconfig.nvim' },
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x',
		event = 'VeryLazy'
	},
	{ 'neovim/nvim-lspconfig' },
	{ 'hrsh7th/cmp-nvim-lsp' },
	{ 'hrsh7th/cmp-path' },
	{ 'hrsh7th/cmp-buffer' },
	{ 'hrsh7th/nvim-cmp' },
	{ 'dcampos/nvim-snippy' },
	{ 'dcampos/cmp-snippy' },
	{
		'nvim-treesitter/nvim-treesitter',
		dependencies = {
			'nvim-treesitter/nvim-treesitter-textobjects',
		},
		build = ':TSUpdate',
	},

	{ "gleam-lang/gleam.vim", event = 'VeryLazy' },
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

	{ -- llm
		"David-Kunz/gen.nvim",
		opts = {
			model = "mistral:7b",
			host = "localhost",
			port = "11434",
		},
		event = 'VeryLazy'
	},
})

-- ------------
-- Plugin config
require("noice").setup({
	lsp = {
		-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
		},
	},
	-- you can enable a preset for easier configuration
	presets = {
		bottom_search = true,    -- use a classic bottom cmdline for search
		command_palette = true,  -- position the cmdline and popupmenu together
		long_message_to_split = false, -- long messages will be sent to a split
		inc_rename = false,      -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = false,  -- add a border to hover docs and signature help
	},
})

require('mini.basics').setup()
require('mini.tabline').setup()
require('mini.statusline').setup()
require('mini.pairs').setup()
require('mini.surround').setup()
require('mini.comment').setup()
require('mini.cursorword').setup()
require('mini.fuzzy').setup()

local function telescope_live_grep_open_files()
	require('telescope.builtin').live_grep {
		grep_open_files = true,
		prompt_title = 'Live Grep in Open Files',
	}
end

require('which-key').register({
	h = {
		name = "Git", -- prefix for Git-related commands
		d = { "<cmd>Gitsigns diffthis<CR>", "Diff" },
		p = { "<cmd>Gitsigns preview_hunk<CR>", "Preview Hunk" },
		r = { "<cmd>Gitsigns reset_hunk<CR>", "Reset Hunk" },
		R = { "<cmd>Gitsigns reset_buffer<CR>", "Reset Buffer" },
		b = { "<cmd>Gitsigns blame_line<CR>", "Blame Line" },
	},
	s = {
		name = "Search", -- prefix for Search-related commands
		f = { require('telescope.builtin').find_files, "Find Files" },
		g = { require('telescope.builtin').git_files, "Git Files" },
		['/'] = { telescope_live_grep_open_files, "Grep Open Files" },
		r = { ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", "Grep with Args" },
	},
	b = {
		name = "Buffer", -- prefix for Buffer-related commands
		c = { ":bdelete<CR>", "Close Buffer" },
		n = { ":bnext<CR>", "Next Buffer" },
		p = { ":bprevious<CR>", "Previous Buffer" },
	},
	g = { "<cmd>LazyGit<CR>", "LazyGit" },
	e = { ":Oil --float<CR>", "Explorer" },
	['<space>'] = { require('telescope.builtin').buffers, "Buffer List" },
	q = { ":qa<CR>", "Quit" },
	w = { ":w<CR>", "Write (Save)" },
}, { prefix = "<leader>" })


require('telescope').load_extension('fzf')
require('telescope').setup {
	defaults = {
		color_devicons = false,
		layout_config = {
			width = 0.7,
			horizontal = {
				preview_width = 0.6
			}
		}
	},
	pickers = {
		buffers = {
			ignore_current_buffer = true,
			sort_lastused = true,
		},
	},
}

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
	end
}

require('nvim-treesitter.configs').setup {
	-- Add languages to be installed here that you want installed for treesitter
	ensure_installed = { 'gleam', 'go', 'lua', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

	-- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
	auto_install = true,
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

local cmp = require('cmp')
cmp.setup({
	snippet = {
		expand = function(args)
			require 'snippy'.expand_snippet(args.body)
		end
	},
	sources = {
		{ name = 'path' },
		{ name = 'nvim_lsp' },
		{ name = 'nvim_lua' },
		{ name = 'snippy',  keyword_length = 2 },
		{ name = 'buffer',  keyword_length = 3 },
	},
	formatting = lsp_zero.cmp_format(),
	mapping = cmp.mapping.preset.insert({
		['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
		['<Tab>'] = cmp.mapping.select_next_item({ behavior = 'select' }),
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
})

-- see :help lsp-zero-guide:integrate-with-mason-nvim
-- to learn how to use mason.nvim with lsp-zero
require('mason').setup({})
require('mason-lspconfig').setup({
	ensure_installed = { 'tsserver', 'gopls', 'lua_ls' },
	handlers = {
		function(server_name)
			require('lspconfig')[server_name].setup({})
		end,
	},
})

require("lspconfig").gleam.setup({})
-- ------------
-- Vim configs
-- vim.cmd("colorscheme cyberdream")

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
