-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',
    -- Required dependency for nvim-dap-ui
    "nvim-neotest/nvim-nio",

    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- virtual text
    'theHamsta/nvim-dap-virtual-text',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require("nvim-dap-virtual-text").setup()
    require('mason').setup()
    -- `See :help mason-nvim-dap.nvim-configuration`
    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      -- automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {
        -- Disable automatic delve setup since we use dap-go
        delve = function() end,
      },

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      -- Update this to ensure that you have the debuggers for the langs you want
      ensure_installed = { 'delve' },
    }

    -- https://github.com/tjdevries/config.nvim/blob/master/lua/custom/plugins/dap.lua
    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<F1>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F2>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F3>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F4>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<F5>', dap.step_back, { desc = 'Debug: Step Back' })
    vim.keymap.set('n', '<F8>', dap.restart, { desc = 'Debug: Restart' })
    vim.keymap.set('n', '<F9>', function ()
      dap.close()
      dapui.close() -- Not sure why event_terminated and event_exited don't seem to call this, so we're calling it here
      -- https://github.com/theHamsta/nvim-dap-virtual-text/blob/fbdb48c2ed45f4a8293d0d483f7730d24467ccb6/lua/nvim-dap-virtual-text.lua#L99
      require('nvim-dap-virtual-text/virtual_text').clear_virtual_text()
    end, { desc = 'Debug: Close' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Conditional Breakpoint' })
    vim.keymap.set('n', '<leader>?', function()
      dapui.eval(nil, { enter = true })
    end, { desc = 'Debug: Eval var under cursor' })
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    -- Install golang specific config
    require('dap-go').setup()

    -- Configure DAP sign colors for better visibility
    vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint' })
    vim.fn.sign_define('DapStopped', { text = '󰳟', texthl = 'DapStopped' })

    -- One time the "●" breakpoint symbol would immediately get replaced by an "R" and this fixed it, weirdly that issue stopped showing up though
    -- vim.fn.sign_define('DapBreakpointCondition', { text = '●', texthl = 'DapBreakpoint' })
    -- vim.fn.sign_define('DapBreakpointRejected', { text = '●', texthl = 'DapBreakpoint' })
    -- vim.fn.sign_define('DapLogPoint', { text = '●', texthl = 'DapBreakpoint' })

    -- Set highlight colors for DAP signs
    vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' }) -- Bright red
    vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#ffcc02' })    -- Bright yellow
  end,
}
