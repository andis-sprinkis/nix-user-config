local wezterm = require 'wezterm';

local cfg_local_status, cfg_local = pcall(require, "cfg_local")

return {
  color_scheme = "vscode-dark",
  font = wezterm.font("Cascadia Code PL"),
  font_size = cfg_local_status and cfg_local['font_size'] or 12.0,
  line_height = 1.29,
  enable_tab_bar = false,
  cursor_blink_rate = 0,
  window_padding = {
    left = 4,
    right = 4,
    top = 4,
    bottom = 4,
  }
}
