---@type ChadrcConfig 
 local M = {}
M.ui = {
    theme = 'github_dark',

    -- https://nvchad.com/docs/config/theming
    hl_override = {
        Visual = { bg = "#444444" }
    }
}
M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"
return M
