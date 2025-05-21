local wezterm = require "wezterm"
local act = wezterm.action

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Eye candy
config.color_scheme = "tokyonight_night"

config.font = wezterm.font "FiraCode Nerd Font Mono"
config.font_size = 10.0

config.window_background_image_hsb = {
  brightness = 0.05,
  saturation = 0.3,
}

if "x86_64-pc-windows-msvc" == wezterm.target_triple then
  config.window_background_image = "C:/Users/catch/Pictures/term-bg.jpg"
end

config.inactive_pane_hsb = {
  saturation = 0.7,
  brightness = 0.2,
}

-- Window configuration
config.hide_tab_bar_if_only_one_tab = true

config.native_macos_fullscreen_mode = true
-- See https://github.com/wez/wezterm/discussions/2506
wezterm.on(
  "gui-startup",
  function(_)
    local _, pane, window = wezterm.mux.spawn_window({})
    local gui_window = window:gui_window();
    gui_window:perform_action(wezterm.action.ToggleFullScreen, pane)
  end
)
config.use_fancy_tab_bar = false

-- Launch behavior
if "x86_64-pc-windows-msvc" == wezterm.target_triple then
  -- Run wsl -l -v in a Windows terminal to get the domain
  config.default_domain = "WSL:Ubuntu"
end

-- Keybindings
-- See also https://github.com/wez/wezterm/discussions/2329
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 700 }
config.keys = {
  { key = "s", mods = "LEADER",      action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "v", mods = "LEADER",      action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "z", mods = "LEADER",      action = act.TogglePaneZoomState },
  { key = "h", mods = "LEADER",      action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER",      action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER",      action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER",      action = act.ActivatePaneDirection("Right") },
  { key = "1", mods = "LEADER",      action = act { ActivateTab = 0 } },
  { key = "2", mods = "LEADER",      action = act { ActivateTab = 1 } },
  { key = "3", mods = "LEADER",      action = act { ActivateTab = 2 } },
  { key = "4", mods = "LEADER",      action = act { ActivateTab = 3 } },
  { key = "5", mods = "LEADER",      action = act { ActivateTab = 4 } },
  { key = "6", mods = "LEADER",      action = act { ActivateTab = 5 } },
  { key = "7", mods = "LEADER",      action = act { ActivateTab = 6 } },
  { key = "8", mods = "LEADER",      action = act { ActivateTab = 7 } },
  { key = "9", mods = "LEADER",      action = act { ActivateTab = 8 } },
  { key = "0", mods = "LEADER",      action = act { ActivateTab = 9 } },
  { key = "x", mods = "LEADER",      action = act { CloseCurrentPane = { confirm = true } } },
  { key = "1", mods = "LEADER|CTRL", action = act.MoveTab(0) },
  { key = "2", mods = "LEADER|CTRL", action = act.MoveTab(1) },
  { key = "3", mods = "LEADER|CTRL", action = act.MoveTab(2) },
  { key = "4", mods = "LEADER|CTRL", action = act.MoveTab(3) },
  { key = "5", mods = "LEADER|CTRL", action = act.MoveTab(4) },
  { key = "6", mods = "LEADER|CTRL", action = act.MoveTab(5) },
  { key = "7", mods = "LEADER|CTRL", action = act.MoveTab(6) },
  { key = "8", mods = "LEADER|CTRL", action = act.MoveTab(7) },
  { key = "9", mods = "LEADER|CTRL", action = act.MoveTab(8) },
  { key = "0", mods = "LEADER|CTRL", action = act.MoveTab(9) },
  { key = "n", mods = "LEADER",      action = act { SpawnTab = "CurrentPaneDomain" } },

  { key = "y", mods = "LEADER",      action = act.QuickSelect },

  {
    key = "e",
    mods = "CTRL|SHIFT",
    action = act.PromptInputLine {
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, _, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
}

return config
