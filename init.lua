-- Reload config: `:source $MYVIMRC`
--
-- Example configs:
-- - https://dev.to/slydragonn/ultimate-neovim-setup-guide-lazynvim-plugin-manager-23b7
--   - https://github.com/slydragonn/nvim-lazy

-- editor options
local o = vim.opt

o.number = true -- line numbers.
o.cursorline = true -- highlight line.
o.ruler = true -- cursor position in modeline.
o.title = true -- Set window title.
o.expandtab = true -- spaces for tabs.
o.shiftwidth = 2 -- autoindent 2 spaces.
o.tabstop = 2 -- tab = 2 spaces.
o.encoding = "UTF-8"
-- NOTE: On Windows when `conceallevel=2 concealcursor="nv"` + highlight line, it will
-- de-indent the line as you go up and down. Fixes are:
--
-- - `:set conceallevel=<0|1>`.
-- - `:set concealcursor=`.
-- Disable line highlighting.
--
-- See: https://vi.stackexchange.com/questions/43359/text-shifts-one-character-to-the-left-when-moving-upwards
o.conceallevel = 2 -- https://nvim-orgmode.github.io/troubleshoot#links-are-not-concealed
o.concealcursor = "" -- Don't conceal when cursor is on that line.
o.scrolloff = 10 -- Scroll buffer when near edge.
vim.g.autoread = true -- reload file if only changed externally.
vim.g.autowrite = true -- Writes on certain events.
vim.g.autowriteall = true -- Write all buffers when switching.

-- NOTE: Downloading spell files is a mess + files were last changed in 2019, so just going
-- to store them in git and symlink!! See: https://ftp.nluug.nl/pub/vim/runtime/spell/
--
o.spelllang = "en_gb,cy" -- `cy_gb` raises: `Warning: region gb not supported`.
o.spell = true

-- https://www.reddit.com/r/neovim/comments/tci7qf/looking_for_an_if_running_on_windows_else/
local uname = vim.loop.os_uname()
_G.OS = uname.sysname
_G.IS_MAC = OS == "Darwin"
_G.IS_LINUX = OS == "Linux"
_G.IS_WINDOWS = OS:find("Windows") and true or false
_G.IS_WSL = IS_LINUX and uname.release:find("Microsoft") and true or false

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- add your plugins here

		{
			"nvim-treesitter/nvim-treesitter",
			config = function()
				require("nvim-treesitter.configs").setup({
					ensure_installed = {
						"json",
						"jsonc", -- DevContainer requirement.
					},
				})
			end,
		},

		{
			-- https://github.com/folke/tokyonight.nvim
			"folke/tokyonight.nvim",
			lazy = false,
			priority = 1000,
			opts = {},
			config = function()
				vim.cmd([[colorscheme tokyonight-night]])
			end,
		},

		-- {
		--   'nvim-telescope/telescope-fzf-native.nvim',
		--   build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
		-- },

		{
			-- Fuzzy searching.
			--  or: tag = '0.1.8', -- Never `master` (apparently).
			"nvim-telescope/telescope.nvim",
			branch = "0.1.x",
			dependencies = {
				"nvim-lua/plenary.nvim", -- required.
				-- Windows: `winget install BurntSushi.ripgrep.MSVC`.
				"BurntSushi/ripgrep", -- required for `live_grep` and `grep_string` and is the first priority for `find_files`.
				-- 'nvim-telescope/telescope-fzf-native',  -- We also suggest you install one native telescope sorter to significantly improve sorting performance.
				"sharkdp/fd", -- Optional: finder.
				"nvim-tree/nvim-web-devicons", -- Optional: icons'
			},
			config = true,
		},

		{
			-- https://nvim-orgmode.github.io/
			-- To build tree-stitter grammars on windows: `winget install zig.zig`
			"nvim-orgmode/orgmode",
			event = "VeryLazy",
			config = function()
				if IS_WINDOWS then
					require("orgmode").setup({
						org_agenda_files = "c:\\src\\org\\**\\*",
						org_default_notes_file = "c:\\src\\org\\inbox.org",
					})
				else
					require("orgmode").setup({
						org_agenda_files = "~/org/**/*",
						org_default_notes_file = "~/org/inbox.org",
					})
				end
			end,
		},

		{
			-- https://github.com/NeogitOrg/neogit
			-- Stage hunk via Visual mode: `V`, then stage: `s`.
			"NeogitOrg/neogit",
			dependencies = {
				"nvim-lua/plenary.nvim", -- required
				"sindrets/diffview.nvim", -- optional - Diff integration

				-- Only one of these is needed.
				"nvim-telescope/telescope.nvim", -- optional
				"ibhagwan/fzf-lua", -- optional
				"echasnovski/mini.pick", -- optional
			},
			config = function()
				require("neogit").setup({
					-- match emacs: magit. https://magit.vc/manual/magit.html#Pulling
					-- https://github.com/NeogitOrg/neogit/issues/985 - Use "F" binding for pulling.
					mappings = {
						popup = {
							["F"] = "PullPopup",
						},
					},
					sections = {
						recent = { folded = false },
						stashes = { folded = false },
						unpulled_pushRemote = { folded = false },
						unpulled_upstream = { folded = false },
					},
				})
			end,
			keys = {
				{ "<leader>g", "<cmd>Neogit cwd=%:p:h<cr>", desc = "Git" },
			},
		},

		{
			-- https://github.com/nvim-lualine/lualine.nvim
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = true,
		},

		{
			-- https://github.com/nvim-neo-tree/neo-tree.nvim
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v3.x",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
				"MunifTanjim/nui.nvim",
				-- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
			},
			config = function()
				require("neo-tree").setup({
					filesystem = {
						filtered_items = {
							hide_hidden = false, -- Windows-only.
							hide_dotfiles = false,
							hide_gitignored = false,
						},
					},
				})
			end,
			keys = {
				{ "<leader>t", "<cmd>Neotree dir=%:p:h:h toggle reveal<cr>", desc = "NeoTree" },
			},
		},

		{
			-- https://github.com/williamboman/mason.nvim
			-- LSP/DAP/etc management.
			"williamboman/mason.nvim",
			dependencies = {
				"williamboman/mason-lspconfig.nvim",
				"WhoIsSethDaniel/mason-tool-installer",
				"neovim/nvim-lspconfig",
				"onsails/lspkind.nvim",
			},
			config = function()
				require("mason").setup()
				require("mason-lspconfig").setup({
					-- https://github.com/williamboman/mason-lspconfig.nvim?tab=readme-ov-file#available-lsp-servers
					ensure_installed = {
						"bashls",
						"bicep",
						"docker_compose_language_service",
						"dockerls",
						"jsonls",
						"lua_ls",
						"marksman",
						"textlsp",
						"yamlls",
					},
				})
				require("mason-lspconfig").setup_handlers({
					-- The first entry (without a key) will be the default handler
					-- and will be called for each installed server that doesn't have
					-- a dedicated handler.
					function(server_name) -- default handler (optional)
						require("lspconfig")[server_name].setup({
							-- capabilities = capabilities,
						})
					end,
				})
				-- After setting up mason-lspconfig you may set up servers via lspconfig
				-- require("lspconfig").lua_ls.setup {}
				-- require("lspconfig").rust_analyzer.setup {}
				-- ...
				require("lspconfig").lua_ls.setup({
					settings = {
						Lua = {
							diagnostics = {
								-- https://neovim.discourse.group/t/how-to-suppress-warning-undefined-global-vim/1882/15
								globals = { "vim" },
							},
						},
					},
				})
				require("mason-tool-installer").setup({
					ensure_installed = {
						-- formatters
						"stylua",
					},
					auto_update = true,
					start_delay = 3000,
					debounce_hours = 5,
				})
			end,
		},

		{
			-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
			-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
			"hrsh7th/nvim-cmp",
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-copilot",
				"ray-x/cmp-treesitter",
				"github/copilot.vim",
				"onsails/lspkind.nvim",
			},
			config = function()
				local cmp = require("cmp")
				require("cmp").setup({
					formatting = {
						format = require("lspkind").cmp_format(),
					},
					-- https://neovim.discourse.group/t/neovim-how-exactly-do-i-use-and-navigate-nvim-cmp/5100/2
					mapping = cmp.mapping.preset.insert({
						["<Up>"] = cmp.mapping.select_prev_item(),
						["<Down>"] = cmp.mapping.select_next_item(),
						["<C-b>"] = cmp.mapping.scroll_docs(-4),
						["<C-f>"] = cmp.mapping.scroll_docs(4),
						["<C-Space>"] = cmp.mapping.complete(),
						["<C-e>"] = cmp.mapping.abort(),
						["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
					}),
					sources = {
						{ name = "copilot" },
						{ name = "nvim_lsp" },
						{ name = "treesitter" },
					},
				})
			end,
		},

		{
			"CopilotC-Nvim/CopilotChat.nvim",
			dependencies = {
				{ "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
				{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
			},
			-- build = "make tiktoken", -- Only on MacOS or Linux
			config = true,
		},

		{
			-- https://github.com/esensar/nvim-dev-container
			"https://codeberg.org/esensar/nvim-dev-container",
			dependencies = "nvim-treesitter/nvim-treesitter",
			config = true,
		},

		{
			-- https://github.com/romgrk/barbar.nvim
			"romgrk/barbar.nvim",
			config = true,
		},

		{
			"folke/which-key.nvim",
			config = function()
				require("which-key").add({
					{ "<leader>f", group = "file" }, -- group
					{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
					{
						"<leader>fb",
						function()
							print("hello")
						end,
						desc = "Foobar",
					},
					{ "<leader>fn", desc = "New File" },
					{ "<leader>f1", hidden = true }, -- hide this keymap
					{ "<leader>w", proxy = "<c-w>", group = "windows" }, -- proxy to window mappings
					{
						"<leader>b",
						group = "buffers",
						expand = function()
							return require("which-key.extras").expand.buf()
						end,
					},
					{
						-- Nested mappings are allowed and can be added in any order
						-- Most attributes can be inherited or overridden on any level
						-- There's no limit to the depth of nesting
						mode = { "n", "v" }, -- NORMAL and VISUAL mode
						{ "<leader>q", "<cmd>q<cr>", desc = "Quit" }, -- no need to specify mode since it's inherited
						{ "<leader>s", "<cmd>w<cr>", desc = "Save" },
					},
				})
				-- -- Show hydra mode for changing windows
				-- wk.show({
				-- keys = "<c-w>",
				-- loop = true, -- this will keep the popup open until you hit <esc>
				-- })
			end,
			event = "VeryLazy",
			opts = {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			},
			keys = {
				{
					"<leader>?",
					function()
						require("which-key").show({ global = false })
					end,
					desc = "Buffer Local Keymaps (which-key)",
				},
			},
		},

		{
			-- https://github.com/cappyzawa/trim.nvim
			"cappyzawa/trim.nvim",
			config = function()
				require("trim").setup({
					trim_first_line = false, -- Don't eat the first line, eg. commit buffers.
					trim_last_line = false, -- Preemptively disabling, most languages want a trailing newline.
					highlight = true,
				})
			end,
		},

		{
			-- https://github.com/stevearc/conform.nvim
			-- Format files.
			"stevearc/conform.nvim",
			opts = {},
			config = function()
				require("conform").setup({
					formatters_by_ft = {
						lua = { "stylua" },
					},
					format_on_save = {
						timeout_ms = 500,
						lsp_format = "fallback",
					},
				})
			end,
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

-- AutoStart plugins
