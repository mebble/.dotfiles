 -- Bootstrap lazy.nvim
 -- From Advent of Neovim by TJ DeVries: https://www.youtube.com/watch?v=_kPg0VBRxJc&list=PLep05UYkc6wTyBe7kPjQFWVXTlhKeQejM&index=4
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
	-- import your plugins
	{
	    "folke/tokyonight.nvim",
	    lazy = false,
	    priority = 1000,
	    opts = {},
	    config = function()
		vim.cmd.colorscheme("tokyonight")
	    end
	},
 
	{
	    "folke/which-key.nvim",
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
	"christoomey/vim-tmux-navigator",

	"tpope/vim-surround",
	"tpope/vim-repeat",

	-- This must be ~/.config/nvim_test/lua/config/plugins/ (ie "lua" is the root module)
	-- Place plugins within it. Ex: ~/.config/nvim_test/lua/config/plugins/tokyonight.nvim
	-- { import = "config.plugins" },

    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})
