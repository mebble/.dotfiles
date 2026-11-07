local prefix = "ctrl+space"
local mod_prefix = prefix .. ">"
local mod_ctrl = "ctrl+"

rex.bind(mod_prefix .. "v", "pane.split.right")
rex.bind(mod_prefix .. "h", "pane.split.down")
rex.bind(mod_prefix .. "z", "pane.zoom")
rex.bind(mod_prefix .. "x", "pane.close")
rex.bind(mod_prefix .. "=", "pane.balance")
rex.bind(mod_prefix .. "f", "pane.float")
rex.bind(mod_prefix .. "c", "client.tab.new")
rex.bind(mod_prefix .. "n", "client.tab.next")
rex.bind(mod_prefix .. "p", "client.tab.previous")
rex.bind(mod_prefix .. "s", "session.switch")
rex.bind(mod_prefix .. "shift+;","client.palette.toggle")

for i = 1, 9 do
  rex.bind(mod_prefix .. i, "client.tab.goto", { index = i })
end

-- prefix ' <digits> enter goes to any tab, like tmux's prefix '
local tab_start_cord = "'>"
local tab_end_cord = ">enter"
for n = 1, 30 do
  local digit_list = {}
  for d in tostring(n):gmatch("%d") do
    digit_list[#digit_list + 1] = d
  end
  rex.bind(mod_prefix .. tab_start_cord .. table.concat(digit_list, ">") .. tab_end_cord, "client.tab.goto", { index = n })
end

local utils = require("utils")

rex.action{
  name  = "prev_active_tab",
  title = "Switch to previous active tab",
  run   = function(ctx, args)
    local active_windows = assert(utils.read_active_windows(ctx.session_id))
    rex.client.queue("session.select", {
      session_id = ctx.session_id,
      window_id  = active_windows.previous,
    })
  end,
}

rex.bind(mod_prefix .. "l", "prev_active_tab")

rex.action{
  name  = "rotate_panes",
  title = "Rotate Panes",
  run   = function(ctx, args)
    local view, err = rex.session.view{}
    if err ~= nil then error(err, 0) end
    for _, window in ipairs(view.windows) do
      if window.window_id == view.active_window_id then
        for _, layer in ipairs(window.layers) do
          if layer.kind == "tiled" then
            local panes = layer.blocks
            for i = #panes, 2, -1 do
              local _, err = rex.session.swap_blocks{
                block_id = panes[1].block_id,
                other_block_id = panes[i].block_id,
              }
              if err ~= nil then error(err, 0) end
            end
            return
          end
        end
        return
      end
    end
  end,
}

rex.bind(mod_prefix .. "ctrl+o", "rotate_panes")

-- prefixes each tab's name with its position, e.g. "1:main:shell"
local tab_number_sep = ":"
rex.action{
  name  = "renumber_tabs",
  title = "Renumber Tabs",
  run   = function(ctx, args)
    local view, err = rex.session.view{}
    if err ~= nil then error(err, 0) end
    for i, w in ipairs(view.windows) do
      local name = (w.label or ""):gsub("^%d+" .. tab_number_sep, "")
      local _, err = rex.session.set_window_label{ window_id = w.window_id, label = i .. tab_number_sep .. name }
      if err ~= nil then error(err, 0) end
    end
  end,
}

rex.bind(mod_ctrl .. "h", "pane.focus.left")
rex.bind(mod_ctrl .. "j", "pane.focus.down")
rex.bind(mod_ctrl .. "k", "pane.focus.up")
rex.bind(mod_ctrl .. "l", "pane.focus.right")

local resize_mode = "resize"
local mod_resize = resize_mode .. "/"

rex.bind("cmd+r", "client.mode.enter", { name = resize_mode })
rex.bind(mod_resize .. "left", "pane.resize", { direction = "left" })
rex.bind(mod_resize .. "right", "pane.resize", { direction = "right" })
rex.bind(mod_resize .. "up", "pane.resize", { direction = "up" })
rex.bind(mod_resize .. "down", "pane.resize", { direction = "down" })
rex.bind(mod_resize .. "=", "pane.balance")

-------------
-- PLUGINS --
-------------

local data = os.getenv('XDG_DATA_HOME') or (os.getenv('HOME') .. '/.local/share')
local plugin = data .. '/nvim/lazy/rex-navigator.nvim'
local ok, err = pcall(function()
  dofile(plugin .. '/rex/navigator.lua').setup()
end)
if not ok then
  rex.log('warn', 'rex-navigator not loaded: ' .. tostring(err))
end
