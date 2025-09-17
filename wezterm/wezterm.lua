local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux
local config = wezterm.config_builder()

config.keys = {
  { key = 'h', mods = 'CTRL', action = act.ActivateTabRelative(-1) },
  { key = 'l', mods = 'CTRL', action = act.ActivateTabRelative(1) },
}

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

-- Finally, return the configuration to wezterm:
return config
