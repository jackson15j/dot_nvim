-- Reload config: `:source $MYVIMRC`
--
-- Example configs:
-- - https://dev.to/slydragonn/ultimate-neovim-setup-guide-lazynvim-plugin-manager-23b7
--   - https://github.com/slydragonn/nvim-lazy

-- editor options
local o = vim.opt

o.number = true  -- line numbers.
o.cursorline = true  -- highlight line.
o.ruler = true  -- cursor position in modeline.
o.title = true  -- Set window title.


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
  -- https://nvim-orgmode.github.io/
  -- To build tree-stitter grammars on windows: `winget install zig.zig`
  'nvim-orgmode/orgmode',
  event = 'VeryLazy',
  config = function()
    require('orgmode').setup({
      org_agenda_files = 'c:\\src\\org\\**\\*',
      org_default_notes_file = 'c:\\src\\org\\inbox.org',
    })
  end,
},

{
  -- https://github.com/NeogitOrg/neogit
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",         -- required
    "sindrets/diffview.nvim",        -- optional - Diff integration

    -- Only one of these is needed.
    "nvim-telescope/telescope.nvim", -- optional
    "ibhagwan/fzf-lua",              -- optional
    "echasnovski/mini.pick",         -- optional
  },
  config = true
},

{
  -- https://github.com/nvim-lualine/lualine.nvim
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
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
            hide_hidden = false,  -- Windows-only.
	    hide_dotfiles = false,
            hide_gitignored = false
	  },
	},
      })
    end,
}





  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- AutoStart plugins
require('lualine').setup()
