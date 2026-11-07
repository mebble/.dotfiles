local M = {}

local home_dir = os.getenv("HOME")
local home_state_dir = home_dir .. "/.local/state"

local function active_window_path(session_id)
  local id = session_id:gsub("^session:", "")
  return home_state_dir .. "/myrex/active_window." .. id .. ".json"
end

M.read_active_windows = function(session_id)
  local f, err = io.open(active_window_path(session_id), "r")
  if f == nil then return nil, err end
  local contents = f:read("*a")
  f:close()
  return rex.json.decode(contents)
end

M.write_active_windows = function(session_id, active_windows)
  local f, err = io.open(active_window_path(session_id), "w")
  if f == nil then return nil, err end
  f:write(rex.json.encode(active_windows, { indent = true }))
  f:close()
  return true
end

M.print_props = function (table)
  for key, val in pairs(table) do
    print(key .. ": " .. tostring(val))
  end
end

return M
