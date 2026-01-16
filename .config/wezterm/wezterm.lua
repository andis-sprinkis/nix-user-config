local wezterm = require('wezterm')
local act = wezterm.action

local M = wezterm.config_builder()

local cfg_local_status, cfg_local = pcall(require, 'cfg_local')

local harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

M.font_size = cfg_local_status and cfg_local['font_size'] or (os.getenv("WAYLAND_DISPLAY") and 13.5 or 12)
M.font = wezterm.font_with_fallback({
  { family = 'Cascadia Code PL', harfbuzz_features = harfbuzz_features },
  { family = 'monospace',        harfbuzz_features = harfbuzz_features },
})
M.adjust_window_size_when_changing_font_size = false
M.color_scheme = 'vscode-dark'
M.cursor_blink_rate = 0
M.cursor_blink_ease_in = 'Constant'
M.cursor_blink_ease_out = 'Constant'
M.force_reverse_video_cursor = true
M.disable_default_key_bindings = true
M.enable_tab_bar = false
M.freetype_load_target = 'Light'
M.line_height = 1.29
M.max_fps = 75
M.initial_cols = 120
M.initial_rows = 30
M.animation_fps = 1
M.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
-- Requires nightly
-- M.window_decorations = "TITLE | RESIZE | MACOS_USE_BACKGROUND_COLOR_AS_TITLEBAR_COLOR"
-- https://wezterm.org/config/lua/config/window_decorations.html
-- Requires nightly
-- M.window_content_alignment = { horizontal = 'Center', vertical = 'Top' }
-- https://wezterm.org/config/lua/config/window_content_alignment.html
M.keys = {
  { key = ')',        mods = 'CTRL',       action = act.ResetFontSize },
  { key = '+',        mods = 'CTRL',       action = act.IncreaseFontSize },
  { key = '-',        mods = 'CTRL',       action = act.DecreaseFontSize },
  { key = '0',        mods = 'CTRL',       action = act.ResetFontSize },
  { key = '=',        mods = 'CTRL',       action = act.IncreaseFontSize },
  { key = 'c',        mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
  { key = 'Copy',     mods = 'NONE',       action = act.CopyTo 'Clipboard' },
  { key = 'Insert',   mods = 'CTRL',       action = act.CopyTo 'PrimarySelection' },
  { key = 'Insert',   mods = 'SHIFT',      action = act.PasteFrom 'PrimarySelection' },
  { key = 'PageDown', mods = 'SHIFT',      action = act.ScrollByPage(1) },
  { key = 'PageUp',   mods = 'SHIFT',      action = act.ScrollByPage(-1) },
  { key = 'Paste',    mods = 'NONE',       action = act.PasteFrom 'Clipboard' },
  { key = 'v',        mods = 'SHIFT|CTRL', action = act.PasteFrom 'Clipboard' },
  { key = '_',        mods = 'CTRL',       action = act.DecreaseFontSize },
}

M.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'CTRL',
    action = act.IncreaseFontSize,
  },
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'CTRL',
    action = act.DecreaseFontSize,
  },
}

if (wezterm.target_triple == 'aarch64-apple-darwin' or wezterm.target_triple == 'x86_64-apple-darwin') then
  table.insert(M.keys, { key = 'Enter', mods = 'CMD', action = act.SpawnCommandInNewWindow })
  table.insert(M.keys, { key = 'v', mods = 'SHIFT|CMD', action = act.PasteFrom 'Clipboard' })
  table.insert(M.keys, { key = 'c', mods = 'SHIFT|CMD', action = act.CopyTo 'Clipboard' })

  table.insert(
    M.mouse_bindings,
    {
      event = { Down = { streak = 1, button = { WheelUp = 1 } } },
      mods = 'SUPER',
      action = act.IncreaseFontSize,
    }
  )
  table.insert(
    M.mouse_bindings,
    {
      event = { Down = { streak = 1, button = { WheelDown = 1 } } },
      mods = 'SUPER',
      action = act.DecreaseFontSize,
    }
  )
end

return M
