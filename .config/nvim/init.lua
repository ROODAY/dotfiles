vim.cmd("source ~/.vimrc")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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

vim.g.mapleader = "\\" -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "\\" -- Same for `maplocalleader`

require("lazy").setup({
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {},
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd("colorscheme tokyonight")
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
	{ -- completion source for require statements and module annotations
		"hrsh7th/nvim-cmp",
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			table.insert(opts.sources, {
				name = "lazydev",
				group_index = 0, -- skip loading LuaLS completions
			})
		end,
	},
	"mhartington/formatter.nvim",
	{
		"glacambre/firenvim",
		-- Only load when Neovim is started by firenvim (in the browser)
		lazy = not vim.g.started_by_firenvim,
		build = function()
			-- Load the plugin first so firenvim#install exists
			require("lazy").load({ plugins = { "firenvim" }, wait = true })
			vim.fn["firenvim#install"](0)
		end,
	},
})

-- Formatter setup (guarded so a missing plugin doesn't break startup)
local ok, util = pcall(require, "formatter.util")
if ok then
	require("formatter").setup({
		logging = true,
		log_level = vim.log.levels.WARN,
		filetype = {
			lua = {
				require("formatter.filetypes.lua").stylua,
				function()
					if util.get_current_buffer_file_name() == "special.lua" then
						return nil
					end
					return {
						exe = "stylua",
						args = {
							"--search-parent-directories",
							"--stdin-filepath",
							util.escape_path(util.get_current_buffer_file_path()),
							"--",
							"-",
						},
						stdin = true,
					}
				end,
			},
			["*"] = {
				require("formatter.filetypes.any").remove_trailing_whitespace,
			},
		},
	})

	vim.keymap.set("n", "<leader>f", ":Format<CR>", { silent = true })
	vim.keymap.set("n", "<leader>F", ":FormatWrite<CR>", { silent = true })

	local group = vim.api.nvim_create_augroup("__formatter__", { clear = true })
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		command = ":FormatWrite",
	})
end

