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

	-- DAP plugins
	{
		'mfussenegger/nvim-dap',
		dependencies = {
			"leoluz/nvim-dap-go",
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dap = require "dap"
			local ui = require "dapui"

			require("dapui").setup()
			require("dap-go").setup()

			dap.listeners.before.attach.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				ui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				ui.close()
			end
		end
	},

	-- LSP plugins
	{
		'williamboman/mason.nvim',
		opts = {
			PATH = "append",
		}
	},
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

	{
		'mrcjkb/haskell-tools.nvim',
		version = '^3', -- Recommended
		lazy = false, -- This plugin is already lazy
	},
	{             -- llm
		"David-Kunz/gen.nvim",
		opts = {
			model = "codegemma:7b",
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

local dap = require "dap"
local ui = require "dapui"

local wk = require("which-key")
wk.add({
	-- Git-related commands
	{ "<leader>h",       group = "Git" },
	{ "<leader>hd",      "<cmd>Gitsigns diffthis<CR>",                                                   desc = "Diff" },
	{ "<leader>hp",      "<cmd>Gitsigns preview_hunk<CR>",                                               desc = "Preview Hunk" },
	{ "<leader>hr",      "<cmd>Gitsigns reset_hunk<CR>",                                                 desc = "Reset Hunk" },
	{ "<leader>hR",      "<cmd>Gitsigns reset_buffer<CR>",                                               desc = "Reset Buffer" },
	{ "<leader>hb",      "<cmd>Gitsigns blame_line<CR>",                                                 desc = "Blame Line" },

	-- Search-related commands
	{ "<leader>s",       group = "Search" },
	{ "<leader>sf",      "<cmd>Telescope find_files<cr>",                                                desc = "Find Files" },
	{ "<leader>sg",      "<cmd>Telescope git_files<cr>",                                                 desc = "Git Files" },
	{ "<leader>s/",      "<cmd>Telescope live_grep<cr>",                                                 desc = "Grep Open Files" },
	{ "<leader>sr",      function() require('telescope').extensions.live_grep_args.live_grep_args() end, desc = "Grep with Args" },

	-- Buffer-related commands
	{ "<leader>b",       group = "Buffer" },
	{ "<leader>bc",      "<cmd>bdelete<CR>",                                                             desc = "Close Buffer" },
	{ "<leader>bn",      "<cmd>bnext<CR>",                                                               desc = "Next Buffer" },
	{ "<leader>bp",      "<cmd>bprevious<CR>",                                                           desc = "Previous Buffer" },

	{ "<leader>d",       group = "Debugger" },
	{ "<leader>?",       function() require("dapui").eval(nil, { enter = true }) end,                    hidden = true,             desc = "Eval under cursor" },
	{ "<F5>",            "<cmd>bprevious<CR>",                                                           desc = "Toggle breakpoint" },
	{ "<F6>",            "<cmd>bprevious<CR>",                                                           desc = "Continue" },
	{ "<F7>",            "<cmd>bprevious<CR>",                                                           desc = "Restart" },
	{ "<F8>",            "<cmd>bprevious<CR>",                                                           desc = "Step over" },
	{ "<F9>",            "<cmd>bprevious<CR>",                                                           desc = "Step into" },
	{ "<F10>",           "<cmd>bprevious<CR>",                                                           desc = "Step out" },

	-- Miscellaneous commands
	{ "<leader>g",       "<cmd>LazyGit<CR>",                                                             desc = "LazyGit" },
	{ "<leader>e",       "<cmd>Oil --float<CR>",                                                         desc = "Explorer" },
	{ "<leader><space>", "<cmd>Telescope buffers<cr>",                                                   desc = "Buffer List" },
	{ "<leader>q",       "<cmd>qa<CR>",                                                                  desc = "Quit" },
	{ "<leader>w",       "<cmd>w<CR>",                                                                   desc = "Write (Save)" },
})


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
vim.cmd("colorscheme cyberdream")

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
