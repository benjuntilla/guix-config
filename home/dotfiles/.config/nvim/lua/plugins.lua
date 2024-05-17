return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'
	use {
		'navarasu/onedark.nvim',
		config = function()
			require('onedark').setup {
				style = 'darker',
				ending_tildes = true
			}
			require('onedark').load()
		end
	}
	use {
		'nvim-lualine/lualine.nvim',
		config = function()
			require('lualine').setup {
				options = {
					theme = 'onedark'
				}
			}
		end,
		requires = { 'nvim-tree/nvim-web-devicons', opt = true }
	}
	use {
		'lukas-reineke/indent-blankline.nvim',
		config = function()
			require("ibl").setup()
		end
	}
	use 'tpope/vim-fugitive'
	use 'preservim/nerdcommenter'
	use 'mg979/vim-visual-multi'
	use 'simnalamburt/vim-mundo'
	use 'matze/vim-move'
	use 'ryanoasis/vim-devicons'
	use 'tpope/vim-surround'
	use 'lambdalisue/suda.vim'
--	use {
--		"zbirenbaum/copilot.lua",
--		cmd = "Copilot",
--		event = "InsertEnter",
--		config = function()
--			require("copilot").setup({})
--		end,
--	}
	use {
		'nvim-treesitter/nvim-treesitter',
		config = function()
			require('nvim-treesitter.configs').setup {
				highlight = {
					enable = true,
					-- Required for spellcheck, some LaTex highlights and
					-- code block highlights that do not have ts grammar
					additional_vim_regex_highlighting = {'org'},
				},
				ensure_installed = {'org'},
			}
		end
	}
	use {
		'nvim-orgmode/orgmode',
		config = function()
			require('orgmode').setup {
				org_agenda_files = {'~/org/*'},
				org_default_notes_file = '~/org/inbox.org',
				org_startup_folded = 'showeverything',
			}
			require('orgmode').setup_ts_grammar()
		end
	}
	use {
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup()
		end
	}
	use {
		'jose-elias-alvarez/null-ls.nvim',
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.diagnostics.eslint,
					null_ls.builtins.completion.spell,
				},
			})
		end,
		requires = {'nvim-lua/plenary.nvim'}
	}
	use {
		"folke/trouble.nvim",
		requires = "nvim-tree/nvim-web-devicons",
		config = function()
			require("trouble").setup {}
		end
	}
	use {
		"folke/which-key.nvim",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			require("which-key").setup {}
		end
	}
	use {
		"windwp/nvim-autopairs",
		config = function() require("nvim-autopairs").setup {} end
	}
	use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }
	use {
		'nvim-telescope/telescope.nvim',
		requires = { 'nvim-lua/plenary.nvim' }
	}
	use {
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
		run = ":MasonUpdate"
	}
	use	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup {
				ensure_installed = { "lua_ls", "rust_analyzer" }
			}
		end,
		after = "mason.nvim"
	}
	use {
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup {}
			lspconfig.rust_analyzer.setup {}
		end,
		after = {"mason.nvim", "mason-lspconfig.nvim"}
	}
end)
