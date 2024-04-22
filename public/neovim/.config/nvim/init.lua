--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- [[ Variables ]]
local sidePaneWidth = 50

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Quality of life
  {
    'tpope/vim-surround',
    config = function()
      -- For visual mode in vim-surround
      -- https://www.youtube.com/watch?v=pTVLA62CNqg
      vim.keymap.set('x', 's', 'S', { remap = true })
    end
  },
  'tpope/vim-repeat',
  'michaeljsmith/vim-indent-object',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
    config = function()
      -- Diagnostic keymaps
      vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_prev, { desc = '[D]iagnostic: Go to [P]revious diagnostic message' })
      vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_next, { desc = '[D]iagnostic: Go to [N]ext diagnostic message' })
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Diagnostic: Open floating diagnostic message' })
      vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostic: Open diagnostics list' })

      --  This function gets run when an LSP connects to a particular buffer.
      local on_attach = function(client, bufnr)
        -- NOTE: Remember that lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself
        -- many times.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local nmap = function(keys, func, desc)
          if desc then
            desc = 'LSP: ' .. desc
          end

          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
        end

        nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition #leaderless')
        nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences #leaderless')
        nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation #leaderless')
        nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
        nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- See `:help K` for why this keymap
        nmap('K', vim.lsp.buf.hover, 'Hover Documentation #leaderless')
        nmap('gs', vim.lsp.buf.signature_help, '[G]oto [S]ignature Documentation #leaderless')

        -- Lesser used LSP functionality
        nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration #leaderless')
        nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
        nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
        nmap('<leader>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, '[W]orkspace [L]ist Folders')

        -- Create a command `:Format` local to the LSP buffer
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
          vim.lsp.buf.format()
        end, { desc = 'Format current buffer with LSP' })
        nmap('<leader>fm', '<cmd>Format<CR>', '[F]or[M]at')

        -- Conjure buffer detach LSP
        -- https://www.reddit.com/r/neovim/comments/xqogsu/turning_off_treesitter_and_lsp_for_specific_files/
        local bufname = vim.fn.expand("%")
        local is_conjure = string.match(bufname, "^conjure%-log%-[0-9]+%.cljc$")
        if is_conjure then
          vim.lsp.buf_detach_client(bufnr, client.id)
        end
      end

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. They will be passed to
      --  the `settings` field of the server config. You must look up that documentation yourself.
      --
      --  If you want to override the default filetypes that your language server will attach to you can
      --  define the property 'filetypes' to the map in question.
      -- https://github.com/neovim/nvim-lspconfig
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
      local servers = {
        -- clangd = {},
        gopls = {},
        pyright = {},
        clojure_lsp = {},
        -- rust_analyzer = {},
        tsserver = {},
        denols = {
          autostart = false
        },
        html = { filetypes = { 'html', 'twig', 'hbs'} },

        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      }

      -- Setup neovim lua configuration
      require('neodev').setup()

      -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization
      -- See `:help nvim_open_win()`
      local handlers = {
        ["textDocument/hover"]         =  vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
        ["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' }),
      }
      vim.diagnostic.config {
        float = { border = 'rounded' },
      }

      -- Ensure the servers above are installed
      local mason_lspconfig = require 'mason-lspconfig'

      mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
      }

      mason_lspconfig.setup_handlers {
        function(server_name)
          require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
            autostart = servers[server_name].autostart,
            handlers = handlers,
          }
        end
      }
    end
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      require('luasnip.loaders.from_vscode').lazy_load()

      -- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#config-options
      luasnip.config.setup {}
      luasnip.add_snippets("clojure", {
        luasnip.parser.parse_snippet("prn-doto", "(#(doto % prn))"),
        luasnip.parser.parse_snippet("prn-let", "_ (prn $1)"),
      })

      cmp.setup {
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete {},

          -- See `:help cmp.confirm`
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Insert,
            select = false,
          },

          -- https://www.youtube.com/watch?v=_DnmphIwnjo&t=7m49s
          ['<Tab>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = "buffer" },
          { name = "nvim_lua" },
          { name = "path" },
        },
      }
    end
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk, { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
        vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
        vim.keymap.set('n', '<leader>gh', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[G]it preview [H]unk' })
      end,
    },
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      -- [[ Configure colorscheme catppuccin ]]
      require('catppuccin').setup {
        custom_highlights = function(colors)
          return {
            LineNr = { fg = colors.surface2 }
          }
        end
      }
      -- setup must be called before loading
      vim.cmd.colorscheme 'catppuccin'
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        disabled_filetypes = {
          'NvimTree',
          'undotree',
          'diff',
        },
      },
      sections = {
        lualine_c = {
          {
            'filename',
            path = 1,
          }
        },
        lualine_x = {
          function()
            return vim.t.maximized and '   ' or ''
          end,
          'encoding',
          'filetype',
        },
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    main = "ibl",
    opts = {
      scope = {
        enabled = false,
      }
    },
  },

  -- "gc" to comment visual regions/lines
  {
    'numToStr/Comment.nvim',
    -- See `:help comment.config`
    opts = {
      toggler = { line = 'gll' }, -- #leaderless
      opleader = { line = 'gl' }, -- #leaderless
    },
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function ()
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        defaults = {
          -- See `:help telescope.defaults.cache_picker`
          cache_picker = {
            num_pickers = 10,
            limit_entries = 50,
          },

          -- See `:help telescope.layout`
          layout_strategy = 'horizontal',
          layout_config = {
            prompt_position = 'top',
            preview_width = 75,
          },

          -- See `:help telescope.defaults.sorting_strategy`
          sorting_strategy = 'ascending',

          -- See `:help telescope.mappings`
          mappings = {
            i = {
              ['<C-u>'] = require('telescope.actions').preview_scrolling_up,
              ['<C-d>'] = require('telescope.actions').preview_scrolling_down,
              ["<C-e>"] = require('telescope.actions').send_to_loclist + require('telescope.actions').open_loclist,
              ["<M-e>"] = require('telescope.actions').send_selected_to_loclist + require('telescope.actions').open_loclist,
              ['<C-v>'] = require('telescope.actions').select_vertical,
              ['<C-s>'] = require('telescope.actions').select_horizontal,

              -- https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md
              -- https://www.reddit.com/r/neovim/comments/tnj64d/question_telescope_opening_files_with_the_ability/
              -- https://github.com/nvim-tree/nvim-tree.lua/blob/a3aa3b47eac8b6289f028743bef4ce9eb0f6782e/lua/nvim-tree/actions/node/open-file.lua#L126
              ["<C-g>"] = function(prompt_bufnr)
                local actions = require "telescope.actions"
                local action_state = require "telescope.actions.state"

                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local path = selection.filename or selection[1]

                require("nvim-tree.actions.node.open-file").fn('edit', path)
              end
            },
          },
        },
        pickers = {
          find_files = {
            follow = true
          },
          lsp_references = {
            include_declaration = false
          },

          -- https://github.com/nvim-telescope/telescope.nvim/issues/2368
          -- lsp_definitions = { jump_type = 'vsplit' },
          -- lsp_implementations = { jump_type = 'vsplit' },
        },
        extensions = {
          file_browser = {
            -- https://github.com/nvim-telescope/telescope-file-browser.nvim/issues/300
            hidden = true,
            follow_symlinks = true,
          }
        },
      }

      -- See `:help telescope.builtin`
      vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
      vim.keymap.set('n', '<leader>/', require('telescope.builtin').current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })
      vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_commits, { desc = 'Search [G]it [C]ommits' })
      vim.keymap.set('n', '<leader>gs', require('telescope.builtin').git_status, { desc = 'Search [G]it [S]tatus' })
      vim.keymap.set('n', '<leader>si', require('telescope.builtin').git_files, { desc = '[S]earch g[I]t files' })
      vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sa', function() require('telescope.builtin').find_files({ hidden = true }) end, { desc = '[S]earch [A]ll files' })
      vim.keymap.set('n', '<leader>sb', require('telescope.builtin').buffers, { desc = '[S]earch [B]uffers' })
      vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sc', require('telescope.builtin').commands, { desc = '[S]earch [C]ommands' })
      vim.keymap.set('n', '<leader>so', require('telescope.builtin').command_history, { desc = '[S]earch [O]ld commands' })
      vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>sp', require('telescope.builtin').pickers, { desc = '[S]earch [P]ickers' })
      vim.keymap.set('n', '<leader>df', require('telescope.builtin').treesitter, { desc = '[D]ocument [F]ymbols (treesitter)' })
      vim.keymap.set('n', '<leader>sn', require('telescope').extensions.luasnip.luasnip, { desc = '[S]earch s[N]ippits' })
      vim.keymap.set('n', '<leader>fb', require('telescope').extensions.file_browser.file_browser, { desc = '[F]ile [B]rowser' })

      -- Enable telescope fzf native, if installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'luasnip')
      pcall(require('telescope').load_extension, 'file_browser')
    end
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },
  {
    "benfowler/telescope-luasnip.nvim",
  },
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    -- See `:help nvim-treesitter`
    opts = {
      -- Add languages to be installed here that you want installed for treesitter
      ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'javascript', 'vimdoc', 'vim', 'query', 'clojure', 'html', 'css', 'java', 'yaml', 'terraform' },

      -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
      auto_install = false,

      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-n>',
          node_decremental = '<c-p>',
          scope_incremental = '<c-s>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']m'] = '@function.outer',
            [']]'] = '@class.outer',
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            [']['] = '@class.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            ['[]'] = '@class.outer',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>a'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>A'] = '@parameter.inner',
          },
        },
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end
  },
  {
    "christoomey/vim-tmux-navigator",
  },

  -- Clojure/lisp plugins https://www.reddit.com/r/Clojure/comments/kolhpj/clojure_in_neovim/
  {
    'guns/vim-sexp',
    config = function ()
      -- https://github.com/guns/vim-sexp/blob/14464d4580af43424ed8f2614d94e62bfa40bb4d/plugin/sexp.vim#L236
      -- https://github.com/guns/vim-sexp/issues/31
      vim.g.sexp_enable_insert_mode_mappings = 0
    end
  },
  'tpope/vim-sexp-mappings-for-regular-people',
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {} -- this is equalent to setup({}) function
  },
  {
    "Olical/conjure",
  },

  {
    'ThePrimeagen/vim-be-good',
  },
  {
    'nvim-tree/nvim-tree.lua',
    opts = {
      -- See `:help nvim-tree-opts-update-focused-file`
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      -- See `:help nvim-tree-opts-view`
      view = {
        side = "right",
        relativenumber = true,
        width = {
          min = sidePaneWidth,
          max = "30%",
        }
      }
    },
    config = function(_, opts)
      -- See `:help nvim-tree-setup`

      -- disable netrw at the very start of your init.lua
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup(opts)

      vim.keymap.set('n', '<C-n>', "<cmd>NvimTreeToggle<CR>", { desc = 'Toggle nvimtree' })
    end
  },
  {
    'nvim-tree/nvim-web-devicons'
  },
  {
    'stevearc/oil.nvim',
    opts = {
      view_options = {
        show_hidden = true,
      }
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function(_, opts)
      require("oil").setup(opts)
    end
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {
      hint_enable = false,
    },
    config = function(_, opts)
      require('lsp_signature').setup(opts)
    end
  },
  {
    "mbbill/undotree",
    config = function ()
      -- See `:help undotree.txt`
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_WindowLayout = 4
      vim.g.undotree_SplitWidth = sidePaneWidth
      vim.keymap.set('n', '<leader>u', '<cmd>UndotreeToggle<CR>', { desc = '[U]ndo tree' })
    end
  },
  {
    'declancm/maximize.nvim',
    opts = {
      default_keymaps = false,
    },
    config = function(_, opts)
      require('maximize').setup(opts)
    end
  },
  {
    'ThePrimeagen/harpoon',
    branch = "harpoon2",
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function ()
      -- See `:help harpoon-getting-started`
      local harpoon = require("harpoon")

      harpoon:setup()
      harpoon:extend({
        SELECT = function(_ctx)
          vim.api.nvim_feedkeys('zz', 'n', true)
        end
      })

      vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() end, { desc = '[H]arpoon [A]dd' })
      vim.keymap.set("n", "<leader>hc", function() harpoon:list():clear() end, { desc = '[H]arpoon [C]lear' })
      vim.keymap.set("n", "<leader>hv", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = '[H]arpoon [V]iew' })

      vim.keymap.set("n", "<leader>n", function() harpoon:list():select(1) end, { desc = 'Harpoon 1' })
      vim.keymap.set("n", "<leader>j", function() harpoon:list():select(2) end, { desc = 'Harpoon 2' })
      vim.keymap.set("n", "<leader>k", function() harpoon:list():select(3) end, { desc = 'Harpoon 3' })
      vim.keymap.set("n", "<leader>p", function() harpoon:list():select(4) end, { desc = 'Harpoon 4' })
    end
  },
  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})


-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

vim.wo.wrap = false
vim.wo.relativenumber = true
vim.cmd([[
" https://jeffkreeftmeijer.com/vim-number/
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,WinEnter * if &nu | set rnu   | endif
  autocmd BufLeave,FocusLost,WinLeave   * if &nu | set nornu | endif
augroup END
]])

-- https://neovim.io/doc/user/lua-guide.html#lua-guide-options
-- https://stackoverflow.com/questions/1878974/redefine-tab-as-4-spaces
vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.tabstop = 8
vim.opt.softtabstop = 0

-- https://stackoverflow.com/a/2054782/5811761
local tabstop_group = vim.api.nvim_create_augroup('GolangTabstop', { clear = true })
vim.api.nvim_create_autocmd('Filetype', {
  callback = function()
    vim.opt_local.tabstop = 4
  end,
  group = tabstop_group,
  pattern = 'go',
})

-- https://stackoverflow.com/a/22614451
vim.o.splitbelow = true
vim.o.splitright = true

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true

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
vim.o.timeoutlen = 200

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
-- Also see https://neovim.io/doc/user/lua-guide.html#lua-guide-mappings
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- https://github.com/NvChad/NvChad/blob/v2.0/lua/core/mappings.lua
vim.keymap.set('n', '<esc>', '<cmd>noh<CR>', { desc = 'Clear highlights' })
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Window left' })  -- Overridden by the tmux navigate equivalents
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Window right' })
vim.keymap.set('n', '<C-h>', '<cmd>TmuxNavigateLeft<CR>', { desc = 'Window left' })
vim.keymap.set('n', '<C-j>', '<cmd>TmuxNavigateDown<CR>', { desc = 'Window down' })
vim.keymap.set('n', '<C-k>', '<cmd>TmuxNavigateUp<CR>', { desc = 'Window up' })
vim.keymap.set('n', '<C-l>', '<cmd>TmuxNavigateRight<CR>', { desc = 'Window right' })
vim.keymap.set('i', '<C-h>', '<Left>', { desc = 'Move left' })
vim.keymap.set('i', '<C-j>', '<Down>', { desc = 'Move down' })
vim.keymap.set('i', '<C-k>', '<Up>', { desc = 'Move up' })
vim.keymap.set('i', '<C-l>', '<Right>', { desc = 'Move right' })

-- https://www.youtube.com/watch?v=w7i4amO_zaE&t=24m24s
-- https://vi.stackexchange.com/questions/38859/what-does-mode-x-mean-in-neovim
-- https://stackoverflow.com/questions/1444322/how-can-i-close-a-buffer-without-closing-the-window
-- https://github.com/neovim/neovim/issues/20126#issuecomment-1694730297
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
-- vim.keymap.set('n', '<C-o>', '<C-o>zz')
-- vim.keymap.set('n', '<C-i>', '<C-i>zz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', '*', '*N')
vim.keymap.set('x', '<leader>y', '"+y', { desc = '[Y]ank to system clipboard' })
vim.keymap.set('x', '[p', '"_dP', { desc = '[P]aste and to blackhole register #leaderless' })
vim.keymap.set({ 'n', 'x' }, '[d', '"_d', { desc = '[D]elete to blackhole register #leaderless' })
vim.keymap.set({ 'n', 'x' }, '[x', '"_x', { desc = '[X]elete to blackhole register #leaderless' })
vim.keymap.set('n', '<leader>x', '<cmd>bp<bar>sp<bar>bn<bar>bd<CR>', { desc = '[X]lose buffer, keep window' })
vim.keymap.set('n', '<leader>o', 'o<esc>0"_D', { desc = 'o, but stay in normal mode' })
vim.keymap.set('n', '<leader>O', 'O<esc>0"_D', { desc = 'O, but stay in normal mode' })
vim.keymap.set('n', '<leader>z', function()
  require('maximize').toggle()
  require('lualine').refresh({
    place = { 'statusline' },
  })
end, { desc = 'Maximi[Z]e window toggle' })
vim.keymap.set('n', '<leader>fn', '<cmd>cnext<CR>zz', { desc = 'Quick[F]ix [N]ext' })
vim.keymap.set('n', '<leader>fp', '<cmd>cprev<CR>zz', { desc = 'Quick[F]ix [P]revious' })
vim.keymap.set('n', '<leader>fc', '<cmd>cclose<CR>', { desc = 'Quick[F]ix [C]lose' })
vim.keymap.set('n', '<leader>fo', '<cmd>colder<CR>', { desc = 'Quick[F]ix View [O]lder list' })
vim.keymap.set('n', '<leader>fi', '<cmd>cnewer<CR>', { desc = 'Quick[F]ix View [I]Newer list' })
vim.keymap.set('n', '<leader>ln', '<cmd>lnext<CR>zz', { desc = '[L]ocation List View [N]ext' })
vim.keymap.set('n', '<leader>lp', '<cmd>lprev<CR>zz', { desc = '[L]ocation List View [P]revious' })
vim.keymap.set('n', '<leader>lc', '<cmd>lclose<CR>', { desc = '[L]ocation List [C]lose' })
vim.keymap.set('n', '<leader>lo', '<cmd>lolder<CR>', { desc = '[L]ocation List View [O]lder list' })
vim.keymap.set('n', '<leader>li', '<cmd>lnewer<CR>', { desc = '[L]ocation List View [I]Newer list' })

-- [[ Custom Text Objects ]]
-- https://thevaluable.dev/vim-create-text-objects/
local chars = { '_', '.', ':', ',', ';', '|', '/', '\\', '*', '+', '%', '`', '?', '-', }
for _, char in ipairs(chars) do
  for _, mode in ipairs({ 'x', 'o' }) do
    -- See `:help nvim_set_keymap` and `:help vim.keymap.set`
    vim.keymap.set(mode, "i" .. char, string.format(':<C-u>silent! normal! f%sF%slvt%s<CR>', char, char, char), { silent = true, desc = string.format('between two %s', char) })
    vim.keymap.set(mode, "a" .. char, string.format(':<C-u>silent! normal! f%sF%svf%s<CR>', char, char, char), { silent = true, desc = string.format('around two %s', char) })
  end
end

-- https://vi.stackexchange.com/a/18081
-- https://www.reddit.com/r/neovim/comments/yg2d9v/how_do_i_exit_the_terminal_mode/
-- vim.keymap.set('i', 'kj', '<esc>')
-- vim.keymap.set('v', 'kj', '<esc>')
-- vim.keymap.set('t', 'kj', [[<C-\><C-n>]])
vim.keymap.set('t', '<esc>', [[<C-\><C-n>]])

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

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
