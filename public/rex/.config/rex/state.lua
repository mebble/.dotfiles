local utils = require("utils")

rex.on("active_window_changed", function(ctx, ev)
  print(ev.type, ev.window_id)

  -- a session's first tab switch has no file yet
  local active_windows = utils.read_active_windows(ctx.session_id) or {}

  active_windows = {
    current = ev.window_id,
    previous = active_windows.current,
  }
  utils.print_props(active_windows)

  assert(utils.write_active_windows(ctx.session_id, active_windows))
end)
