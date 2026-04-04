local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux
local config = wezterm.config_builder()

config.font = wezterm.font 'JetBrains Mono'
config.color_scheme = 'Catppuccin Mocha'

config.default_prog = { 'pwsh' }

config.keys = {
  { key = 'h', mods = 'CTRL', action = act.ActivateTabRelative(-1) },
  { key = 'l', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 't', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'r', mods = 'CTRL', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'j', mods = 'CTRL', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection 'Right' },
  { key = 'w', mods = 'CTRL', action = act.CloseCurrentPane { confirm = false } },
  { key = 'c', mods = 'CTRL', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
  { key = 'h', mods = 'CTRL|SHIFT|ALT', action = act.AdjustPaneSize { 'Left', 2 } },
  { key = 'j', mods = 'CTRL|SHIFT|ALT', action = act.AdjustPaneSize { 'Down', 2 } },
  { key = 'k', mods = 'CTRL|SHIFT|ALT', action = act.AdjustPaneSize { 'Up', 2 } },
  { key = 'l', mods = 'CTRL|SHIFT|ALT', action = act.AdjustPaneSize { 'Right', 2 } },
}

config.mouse_bindings = {
  -- Right click: copy selection if any, otherwise paste
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ''
      if has_selection then
        window:perform_action(act.CompleteSelection 'Clipboard', pane)
      else
        window:perform_action(act.PasteFrom 'Clipboard', pane)
      end
    end),
  },
  -- Prevent copy-on-select: only open links on left button up, don't copy to clipboard
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ''
      if not has_selection then
        window:perform_action(act.CompleteSelectionOrOpenLinkAtMouseCursor 'Clipboard', pane)
      end
    end),
  },
}

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

-- Finally, return the configuration to wezterm:
return config
