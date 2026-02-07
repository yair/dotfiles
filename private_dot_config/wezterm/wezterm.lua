local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- This removes the tab bar entirely
-- config.enable_tab_bar = false

-- This hides it if there's only one
config.hide_tab_bar_if_only_one_tab = true

-- Classic terminal (xterm/rxvt) mouse behavior.
-- Selection goes to PRIMARY only, middle-click pastes, right-click extends.
config.disable_default_mouse_bindings = true
config.mouse_bindings = {
  -- Left click sets selection anchor
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.SelectTextAtMouseCursor 'Cell',
  },
  -- Drag to select text character-by-character
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.ExtendSelectionToMouseCursor 'Cell',
  },
  -- Release completes selection into PRIMARY
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'PrimarySelection',
  },
  -- Double click selects a word
  {
    event = { Down = { streak = 2, button = 'Left' } },
    mods = 'NONE',
    action = act.SelectTextAtMouseCursor 'Word',
  },
  {
    event = { Drag = { streak = 2, button = 'Left' } },
    mods = 'NONE',
    action = act.ExtendSelectionToMouseCursor 'Word',
  },
  {
    event = { Up = { streak = 2, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'PrimarySelection',
  },
  -- Triple click selects a line
  {
    event = { Down = { streak = 3, button = 'Left' } },
    mods = 'NONE',
    action = act.SelectTextAtMouseCursor 'Line',
  },
  {
    event = { Drag = { streak = 3, button = 'Left' } },
    mods = 'NONE',
    action = act.ExtendSelectionToMouseCursor 'Line',
  },
  {
    event = { Up = { streak = 3, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'PrimarySelection',
  },
  -- Right click extends selection
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.ExtendSelectionToMouseCursor 'Cell',
  },
  {
    event = { Up = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.CompleteSelection 'PrimarySelection',
  },
  -- Middle click pastes from PRIMARY
  {
    event = { Down = { streak = 1, button = 'Middle' } },
    mods = 'NONE',
    action = act.PasteFrom 'PrimarySelection',
  },
  -- Scroll wheel scrolls through scrollback (5 lines per notch, like rxvt)
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'NONE',
    action = act.ScrollByLine(-5),
  },
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'NONE',
    action = act.ScrollByLine(5),
  },
  -- Shift+left click extends selection (also works to override app mouse tracking)
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'SHIFT',
    action = act.ExtendSelectionToMouseCursor 'Cell',
  },
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'SHIFT',
    action = act.ExtendSelectionToMouseCursor 'Cell',
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'SHIFT',
    action = act.CompleteSelection 'PrimarySelection',
  },
}

return config

