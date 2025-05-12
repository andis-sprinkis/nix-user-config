local wezterm = require('wezterm')
local act = wezterm.action

local cfg_local_status, cfg_local = pcall(require, 'cfg_local')

local harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

local M = {
  font_size = cfg_local_status and cfg_local['font_size'] or (os.getenv("WAYLAND_DISPLAY") and 13.5 or 12),
  font = wezterm.font_with_fallback({
    { family = 'Cascadia Code PL', harfbuzz_features = harfbuzz_features },
    { family = 'monospace',        harfbuzz_features = harfbuzz_features },
  }),
  adjust_window_size_when_changing_font_size = false,
  color_scheme = 'vscode-dark',
  cursor_blink_rate = 0,
  disable_default_key_bindings = true,
  enable_tab_bar = false,
  freetype_load_target = 'Light',
  line_height = 1.29,
  max_fps = 75,
  initial_cols = 120,
  initial_rows = 30,
  animation_fps = 1,
  window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
  keys = {
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
  },
  mouse_bindings = {
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
  },
}

if (wezterm.target_triple == 'aarch64-apple-darwin' or wezterm.target_triple == 'x86_64-apple-darwin') then
  -- table.insert(
  --   M.keys,
  --   {
  --     key = 'Enter',
  --     mods = 'CMD',
  --     action = act.SpawnCommandInNewWindow,
  --   }
  -- )
  -- table.insert(
  --   M.keys,
  --   {
  --     key = 'v',
  --     mods = 'SHIFT|CMD',
  --     action = act.PasteFrom 'Clipboard',
  --   }
  -- )
  -- table.insert(
  --   M.keys,
  --   {
  --     key = 'c',
  --     mods = 'SHIFT|CMD',
  --     action = act.CopyFrom 'Clipboard',
  --   }
  -- )
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
