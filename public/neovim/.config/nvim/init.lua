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

-- [[ Variables and functions ]]
local sidePaneWidth = 50

local function exit_visual_mode(callback)
  -- Exit visual mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
  vim.defer_fn(callback, 50) -- delay in ms
end

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
  {
    'tpope/vim-fugitive',
    dependencies = {
      'tpope/vim-rhubarb',
    },
    config = function()
      -- https://github.com/tpope/vim-fugitive/issues/1401#issuecomment-555162377
      vim.keymap.set('n', '<leader>gb', function()
        if vim.bo.filetype == 'fugitiveblame' then
          vim.cmd('quit')
        else
          vim.cmd('Git blame')
        end
      end, { desc = '[G]it [B]lame' })

      -- get github link (needs tpope/vim-rhubarb)
      local function gbrowse_link(branch)
        local mode = vim.fn.mode()

        -- when normal mode + branch not given, resolves to current branch + file path (no commit hash)
        -- when normal mode + branch given, resolves to commit hash of given branch + file path
        -- when visual mode, always resolves to commit hash + file path + line range
        local branch_arg = branch and (" " .. branch .. ":%") or ""

        if mode == 'v' or mode == 'V' or mode == '\22' then  -- visual, visual-line, visual-block
          -- Exit visual mode and run GBrowse! on visual selection
          exit_visual_mode(function()
            vim.cmd(":'<,'>GBrowse!" .. branch_arg)
          end)
        else
          vim.cmd("GBrowse!" .. branch_arg)
        end
      end

      vim.keymap.set({ 'n', 'v' }, '<leader>gl', function()
        gbrowse_link()
      end, { desc = 'Copy [G]itHub [l]ink to clipboard' })

      vim.keymap.set({ 'n', 'v' }, '<leader>gL', function()
        gbrowse_link("main")
      end, { desc = 'Copy [G]itHub [L]ink to clipboard (main branch)' })
    end
  },
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
        nmap('gD', vim.lsp.buf.type_definition, '[G]oto Type [D]efinition #leaderless')
        nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences #leaderless')
        nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation #leaderless')
        nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- See `:help K` for why this keymap
        nmap('K', vim.lsp.buf.hover, 'Hover Documentation #leaderless')
        nmap('gs', vim.lsp.buf.signature_help, '[G]oto [S]ignature Documentation #leaderless')

        -- Lesser used LSP functionality
        nmap('<leader>D', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
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
        astro = {},

        -- https://docs.deno.com/runtime/getting_started/setup_your_environment/#neovim-0.6%2B-using-the-built-in-language-server
        denols = {
          root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
        },
        -- https://github.com/neovim/nvim-lspconfig/pull/3232#issuecomment-2331025714
        ts_ls = {
          root_dir = require("lspconfig").util.root_pattern("package.json"),
          single_file_support = false,
        },

        terraformls = {},
        html = { filetypes = { 'html', 'twig', 'hbs'} },

        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },

        tailwindcss = {},
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
      local mason = require('mason')
      local mason_lspconfig = require 'mason-lspconfig'

      mason.setup()
      mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
      }

      -- https://neovim.discourse.group/t/cannot-serialize-function-type-not-supported/4542/3
      mason_lspconfig.setup_handlers {
        function(server_name)
          require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            handlers = handlers,
            autostart = (servers[server_name] or {}).autostart,
            root_dir = (servers[server_name] or {}).root_dir,
            settings = (servers[server_name] or {}).settings,
            filetypes = (servers[server_name] or {}).filetypes,
            single_file_support = (servers[server_name] or {}).single_file_support,
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
          {
            "aerial",
          },
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
      -- {
      --   "nvim-telescope/telescope-frecency.nvim",
      -- },
      {
        "nvim-telescope/telescope-live-grep-args.nvim" ,
        -- This will not install any breaking changes.
        -- For major updates, this must be adjusted manually.
        version = "^1.0.0",
      },
    },
    config = function ()
      local live_grep_args_postfix = " -F "

      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        defaults = {
          -- Three things we might wanna ignore:
          --   - The .git/ folder (we don't wanna ignore .git* like .github)
          --   - The files/dirs listed in .gitignore. These seems to be ignored by all pickers' underlying tools (fzf, rg) even when we include hidden files
          --   - The files/dirs starting with dot (aka hidden). These seem to be ignored by default, and to be configured per picker.
          -- We want to include hidden files/dirs (check the pickers config below), but we still wanna ignore .git/ (a hidden dir)
          file_ignore_patterns = {".git/"},

          -- See `:help telescope.defaults.cache_picker`
          cache_picker = {
            num_pickers = 10,
            limit_entries = 50,
          },

          -- https://github.com/nvim-telescope/telescope.nvim/issues/2014#issuecomment-1166467071
          -- Format path as "file.txt (path\to\file\)"
          -- path_display = function(opts, path)
          --   local tail = require("telescope.utils").path_tail(path)
          --   return string.format("%s (%s)", tail, path), { { { 1, #tail }, "Constant" } }
          -- end,

          path_display = function(_, path)
            local sep = package.config:sub(1, 1)

            local MAX_PART_LEN = 20              -- Max allowed length per part
            local MIN_TRIM_LEN = 3               -- Do not trim if part length is under this
            local TOTAL_LEN_LIMIT = 80           -- Trigger trimming only if combined raw length > this
            local TOP_DIR_COUNT = 5              -- Max number of directories from the root to keep
            local BOTTOM_DIR_COUNT = 3           -- Max number of directories near file to keep
            local LOG_FALLOFF_MULTIPLIER = 10    -- Used to stretch ratio in log-based falloff
            local LOG_FALLOFF_BASE = 11          -- Log base for falloff compression
            local TRIM_FILLER = "…"
            local GAP_FILLER = "..."

            -- Trims a part based on dynamic limit
            local function trim_part_dynamic(part, dynamic_max)
              local len = #part
              if len <= dynamic_max or len <= MIN_TRIM_LEN then
                return part
              end
              local keep = math.floor((dynamic_max - #TRIM_FILLER) / 2)
              if keep < 1 then return TRIM_FILLER end
              return part:sub(1, keep) .. TRIM_FILLER .. part:sub(-keep)
            end

            -- Split full path into parts (dirs + file)
            local parts = vim.split(path, sep)
            local total_parts = #parts

            -- Remove and store the filename separately (tail is unreliable with full duplication cases)
            local filename = table.remove(parts)  -- parts now contains only directory segments
            local base_part = filename

            -- If no directory parts, return filename only — avoid showing ()
            if vim.tbl_isempty(parts) then
              return filename, { { { 1, #filename }, "Constant" } }
            end

            -- Get the first 5 directories from the root
            local top = vim.list_slice(parts, 1, math.min(TOP_DIR_COUNT, total_parts - 1))

            -- Get the last 2 directories before the file
            -- Ensure we skip overlapping segments with 'top'
            local bottom_start = math.max(total_parts - BOTTOM_DIR_COUNT, #top + 1)
            local bottom = vim.list_slice(parts, bottom_start, total_parts - 1)

            local has_bottom = #bottom > 0
            local bottom_overlaps_top = top[#top] == bottom[1] -- Avoid duplicating segments already shown in 'top'
            local has_gap = total_parts - 1 > (#top + #bottom) -- Only show ellipsis if there's a hidden gap between top and bottom

            -- Raw length calculation (excluding formatting)
            local raw_combined_length = 0
            for _, part in ipairs(top) do raw_combined_length = raw_combined_length + #part end
            for _, part in ipairs(bottom) do raw_combined_length = raw_combined_length + #part end
            raw_combined_length = raw_combined_length + #filename + (#top + #bottom + 1) * #sep  -- Add separators

            -- Trim long parts only if combined length is too large
            if raw_combined_length > TOTAL_LEN_LIMIT then
              -- Scale max part length proportionally (inverse function) (X-axis: raw_combined_length, Y-axis: dynamic_max)
              -- Loosen trimming with different falloff options
              local ratio = TOTAL_LEN_LIMIT / raw_combined_length
              -- local dynamic_max = math.max(MIN_TRIM_LEN, math.floor(MAX_PART_LEN * ratio))                                                                        -- linear falloff
              -- local dynamic_max = math.max(MIN_TRIM_LEN, math.floor(MAX_PART_LEN * math.sqrt(ratio)))                                                             -- sqrt falloff
              local dynamic_max = math.max(MIN_TRIM_LEN, math.floor(MAX_PART_LEN * (math.log(1 + ratio * LOG_FALLOFF_MULTIPLIER) / math.log(LOG_FALLOFF_BASE))))     -- log falloff

              for i, part in ipairs(top) do
                top[i] = trim_part_dynamic(part, dynamic_max)
              end
              for i, part in ipairs(bottom) do
                bottom[i] = trim_part_dynamic(part, dynamic_max)
              end
              base_part = trim_part_dynamic(base_part, dynamic_max)
            end

            local context = table.concat(top, sep)
            if has_bottom and not bottom_overlaps_top and has_gap then
              context = context .. sep .. GAP_FILLER .. sep .. table.concat(bottom, sep)
            elseif has_bottom and not bottom_overlaps_top then
              context = context .. sep .. table.concat(bottom, sep)
            end

            context = context .. sep .. base_part

            return string.format("%s (%s)", filename, context), { { { 1, #filename }, "Constant" } }
          end,

          -- See `:help telescope.layout`
          layout_strategy = 'horizontal',
          layout_config = {
            horizontal = { prompt_position = 'top', preview_width = 75 },
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
              ['<C-f>'] = require('telescope.actions').to_fuzzy_refine,

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
            n = {
              ["<C-n>"] = require('telescope.actions').move_selection_next,
              ["<C-p>"] = require('telescope.actions').move_selection_previous,
            },
          },
        },
        pickers = {
          -- https://github.com/nvim-telescope/telescope.nvim/issues/855
          live_grep = {
            additional_args = {"--hidden"}
          },
          grep_string = {
            additional_args = {"--hidden"}
          },
          find_files = {
            follow = true,
            hidden = true,
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
            git_status = false, -- avoids running git, speeding things up
          },
          -- frecency = {
          --   auto_validate = false,
          -- },
          aerial = {
            show_nesting = {
              ["_"] = true,
            },
          },
          live_grep_args = {
            mappings = {
              i = {
                ["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt({ postfix = live_grep_args_postfix }),
              },
            },
            -- temporary, until live_grep_args supports something like additional_args (https://github.com/nvim-telescope/telescope-live-grep-args.nvim/pull/86). Then we can pass additional_args = {"--hidden"}
            vimgrep_arguments = { "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case", "--hidden" },
          }
        },
      }

      -- From https://github.com/nvim-telescope/telescope-live-grep-args.nvim/blob/8ad632f793fd437865f99af5684f78300dac93fb/lua/telescope-live-grep-args/shortcuts.lua#L8
      local function get_visual()
        local _, ls, cs = unpack(vim.fn.getpos("v"))
        local _, le, ce = unpack(vim.fn.getpos("."))

        -- nvim_buf_get_text requires start and end args be in correct order
        ls, le = math.min(ls, le), math.max(ls, le)
        cs, ce = math.min(cs, ce), math.max(cs, ce)

        return vim.api.nvim_buf_get_text(0, ls - 1, cs - 1, le - 1, ce, {})
      end

      -- See `:help telescope.builtin`
      -- vim.keymap.set('n', '<leader>?', require('telescope').extensions.frecency.frecency, { desc = '[?] Find recently opened files' })
      vim.keymap.set('n', '<leader>/', require('telescope.builtin').current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })
      vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_commits, { desc = 'Search [G]it [C]ommits' })
      vim.keymap.set('n', '<leader>gs', require('telescope.builtin').git_status, { desc = 'Search [G]it [S]tatus' })
      vim.keymap.set('n', '<leader>si', require('telescope.builtin').git_files, { desc = '[S]earch g[I]t files' })
      vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sb', require('telescope.builtin').buffers, { desc = '[S]earch [B]uffers' })
      vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('x', '<leader>sw', function() require('telescope.builtin').grep_string({ search = get_visual()[1] or "" }) end, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sW', function() require('telescope.builtin').grep_string({ word_match = '-w' }) end, { desc = '[S]earch current [W]ord (strict)' })
      vim.keymap.set('x', '<leader>sW', function() require('telescope.builtin').grep_string({ search = get_visual()[1] or "", word_match = '-w' }) end, { desc = '[S]earch current [W]ord (strict)' })
      vim.keymap.set('n', "<leader>sg", require('telescope').extensions.live_grep_args.live_grep_args, { desc = '[S]earch by [G]rep' }) -- replaces require('telescope.builtin').live_grep
      vim.keymap.set('x', "<leader>sg", function() require('telescope-live-grep-args.shortcuts').grep_visual_selection({ postfix = live_grep_args_postfix }) end, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sc', require('telescope.builtin').commands, { desc = '[S]earch [C]ommands' })
      vim.keymap.set('n', '<leader>so', require('telescope.builtin').command_history, { desc = '[S]earch [O]ld commands' })
      vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>sp', require('telescope.builtin').pickers, { desc = '[S]earch [P]ickers' })
      vim.keymap.set('n', '<leader>df', require('telescope.builtin').treesitter, { desc = '[D]ocument [F]ymbols (treesitter)' })
      vim.keymap.set('n', '<leader>sn', require('telescope').extensions.luasnip.luasnip, { desc = '[S]earch s[N]ippits' })
      vim.keymap.set('n', '<leader>fb', "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>", { desc = '[F]ile [B]rowser' })
      vim.keymap.set('n', '<leader>di', function ()
        require('telescope').extensions.aerial.aerial({
          on_complete = {
            function(picker)
              picker:set_selection(picker:get_row(1))
            end
          }
        })
      end, { desc = '[D]ocument Aer[I]al' })

      -- Enable telescope fzf native, if installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'luasnip')
      pcall(require('telescope').load_extension, 'file_browser')
      -- pcall(require('telescope').load_extension, "frecency")
      pcall(require('telescope').load_extension, "aerial")
      pcall(require('telescope').load_extension, "live_grep_args")
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
      ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'javascript', 'vimdoc', 'vim', 'query', 'clojure', 'html', 'css', 'java', 'yaml', 'terraform', 'astro', 'json' },

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
  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require'treesitter-context'.setup{
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        mode = 'topline',  -- Line used to calculate context. Choices: 'cursor', 'topline'
        separator = '-',
      }
    end
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
      vim.keymap.set('n', '<C-f>', "<cmd>NvimTreeFocus<CR>", { desc = 'Focus nvimtree' })
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
    config = true
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

      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = '[H]arpoon [A]dd' })
      vim.keymap.set("n", "<leader>hc", function() harpoon:list():clear() end, { desc = '[H]arpoon [C]lear' })
      vim.keymap.set("n", "<leader>hv", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = '[H]arpoon [V]iew' })

      vim.keymap.set("n", "<leader>n", function() harpoon:list():select(1) end, { desc = 'Harpoon 1' })
      vim.keymap.set("n", "<leader>j", function() harpoon:list():select(2) end, { desc = 'Harpoon 2' })
      vim.keymap.set("n", "<leader>k", function() harpoon:list():select(3) end, { desc = 'Harpoon 3' })
      vim.keymap.set("n", "<leader>p", function() harpoon:list():select(4) end, { desc = 'Harpoon 4' })
    end
  },
  {
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("aerial").setup({
        manage_folds = true,
        link_tree_to_folds = true,
      })
      vim.keymap.set('n', '<leader>i', "<cmd>AerialToggle<CR>", { desc = 'Aer[I]al Toggle' })
    end
  },
  {
    'smoka7/hop.nvim',
    version = "*",
    opts = {
      keys = 'etovxqpdygfblzhckisuran'
    },
    config = function (opts)
      local hop = require('hop')
      hop.setup(opts)

      -- See `:h hop-lua-api and :h hop-config`
      vim.keymap.set({"n", "x"}, "zj", hop.hint_words, { desc = 'Hop Word' })
      vim.keymap.set({"n", "x"}, "zk", function() hop.hint_words({ current_line_only = true }) end, { desc = 'Hop Find' })
    end
  },

  -- Markdown plugins
  -- https://www.youtube.com/watch?v=DgKI4hZ4EEI
  {
    "epwalsh/obsidian.nvim",
    version = "*",  -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("obsidian").setup{
        workspaces = {
          {
            name = "Notes",
            path = "~/Documents/notes",
          },
        },
        ui = {
          -- enable = false, -- disable otherwise it conflicts with render-markdown.nvim
          checkboxes = {
            [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
            ["x"] = { char = "", hl_group = "ObsidianDone" },
            ["!"] = { char = "", hl_group = "ObsidianImportant" },
            [">"] = { char = "", hl_group = "ObsidianRightArrow" },
            ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
          },
        },
      }

      vim.keymap.set('n', '<leader>st', '<cmd>ObsidianTags<CR>', { desc = '[S]earch Obsidian [T]ags' })

      -- For obsidian.nvim to render markdown
      local obsidian_markdown_group = vim.api.nvim_create_augroup('ObsidianMarkdownGroup', { clear = true })
      vim.api.nvim_create_autocmd('Filetype', {
        callback = function()
          vim.opt_local.conceallevel = 1
        end,
        group = obsidian_markdown_group,
        pattern = 'markdown',
      })
    end
  },

  {
    "supermaven-inc/supermaven-nvim",
    opts = {},
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<C-y>",
        }
      })
    end,
  },
  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  require 'kickstart.plugins.debug',

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

-- Enable word wrap for markdown files
local markdown_group = vim.api.nvim_create_augroup("MarkdownSettings", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true         -- Enable soft wrapping (i.e. make it appear wrapped, but in reality its all on a line)
    vim.opt_local.linebreak = true    -- Wrap at word boundaries only

    -- Set up a buffer-local keymap to toggle wrap
    vim.keymap.set("n", "<leader>ww", function()
      local new_wrap = not vim.opt_local.wrap:get()
      vim.opt_local.wrap = new_wrap
      vim.opt_local.linebreak = new_wrap
    end, { buffer = true, desc = "Toggle [W]ord [W]rap" })
  end,
  group = markdown_group,
})

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
vim.o.timeoutlen = 300

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
-- vim.keymap.set('n', 'N', 'Nzz')
-- vim.keymap.set('n', 'n', 'nzz')
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

-- Copy absolute dir path
vim.keymap.set("n", "<leader>cd", function()
  local bufname = vim.api.nvim_buf_get_name(0)
  local dir_path = vim.fn.fnamemodify(bufname, ":p:h")
  vim.fn.setreg("+", dir_path)  -- Copy to system clipboard
  vim.notify("Copied dir path: " .. dir_path)
end, { noremap = true, silent = true, desc = "[C]opy file [D]ir path" })
-- Copy relative file path
vim.keymap.set("n", "<leader>cp", function()
  local bufname = vim.api.nvim_buf_get_name(0)
  local rel_path = vim.fn.fnamemodify(bufname, ":.")
  vim.fn.setreg("+", rel_path)  -- Copy to system clipboard
  vim.notify("Copied file path: " .. rel_path)
end, { noremap = true, silent = true, desc = "[C]opy file [P]ath" })
-- Copy relative file path (visual)
vim.keymap.set("v", "<leader>cp", function()
  local bufname = vim.api.nvim_buf_get_name(0)
  local rel_path = vim.fn.fnamemodify(bufname, ":.")

  -- Get visual selection start and end lines
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local line_suffix = start_line == end_line
      and (":" .. start_line)
      or (":" .. start_line .. "-" .. end_line)

  local result = rel_path .. line_suffix

  vim.fn.setreg("+", result)

  exit_visual_mode(function()
    vim.notify("Copied file path: " .. result)
  end)
end, { noremap = true, silent = true, desc = "[C]opy file [P]ath" })

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

local function escape_key(key)
  -- If key is alphanumeric and underscore only, use dot notation
  if key:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
    return "." .. key
  else
    return "['" .. key .. "']"
  end
end

-- Works for strict JSON, not JSON5 etc
local function copy_json_path(include_leading_dot)
  local ft = vim.bo.filetype
  if ft ~= "json" then
    -- print("Not a JSON file")
    vim.notify("Not a JSON file", vim.log.levels.WARN)
    return
  end

  local ts_utils = require("nvim-treesitter.ts_utils")

  local node = ts_utils.get_node_at_cursor()
  if not node then
    vim.notify("No syntax node found at cursor", vim.log.levels.WARN)
    return
  end

  -- Traverse up until we hit a pair or array
  local path_parts = {}
  while node do
    local node_type = node:type()

    if node_type == "pair" then
      -- Get key name
      local key_node = node:child(0)
      if key_node and key_node:type() == "string" then
        local key_text = vim.treesitter.get_node_text(key_node, 0)
        key_text = key_text:gsub('^"(.*)"$', '%1') -- remove quotes
        table.insert(path_parts, 1, escape_key(key_text))
      end
    elseif node:parent() and node:parent():type() == "array" then
      local parent = node:parent()
      for i = 0, parent:named_child_count() - 1 do
        if parent:named_child(i) == node then
          table.insert(path_parts, 1, "[" .. i .. "]")
          break
        end
      end
    end
    node = node:parent()
  end

  local json_path = table.concat(path_parts)
  if not include_leading_dot then
    json_path = json_path:gsub("^%.", "")
  end
  vim.fn.setreg("+", json_path) -- Copy to system clipboard
  vim.notify("Copied JSON path: " .. json_path)
end

vim.keymap.set("n", "<leader>cj", function() copy_json_path(false) end, { desc = "[C]opy [J]son path" })
vim.keymap.set("n", "<leader>cJ", function() copy_json_path(true) end, { desc = "[C]opy [J]son path (with leading dot)" })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
