local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- This removes the tab bar entirely
-- config.enable_tab_bar = false

-- This hides it if there's only one
config.hide_tab_bar_if_only_one_tab = true

return config

