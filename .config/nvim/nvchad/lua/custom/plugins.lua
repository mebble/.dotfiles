local plugins = {
    {
        "neovim/nvim-lspconfig",
        config = function()
            require "plugins.configs.lspconfig"
            require "custom.configs.lspconfig"
        end,
    },
    {
        -- This config will ensure that these packages are installed by mason. If we want to use a globally installed package (say with brew, apt-get, npm -g etc) then no need to mention the package here, otherwise mason will install it and we'd end up with two installations of the same thing.
        -- Mason packages must be listed in the registry: https://mason-registry.dev/registry/list
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "lua-language-server",
                "clojure-lsp",
                "typescript-language-server",
                "pyright",
            },
        },
    },
    {
        'ThePrimeagen/vim-be-good',
    },
    {
        -- https://github.com/NvChad/NvChad/issues/2111
        "nvim-telescope/telescope.nvim",
        opts = {
            defaults = {
                prompt_prefix = " 👉 "
            },
        },
        dependencies = {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
            lazy = false,
            config = function ()
                require('telescope').load_extension('fzf')
            end
        }
    },
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim",
        },
        lazy = false,
        config = function ()
            require('telescope').load_extension('file_browser')
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "lua",
                "python",
                "clojure",
            }
        }
    },
    {
        "christoomey/vim-tmux-navigator",
        lazy = false,
    },
    {
        "Olical/conjure",
        lazy = false,
    }
}

return plugins
