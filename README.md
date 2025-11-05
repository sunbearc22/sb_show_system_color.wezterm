# sb_show_system_color.wezterm

 This plugin obtains the System's theme and color and the shades, tints, triadic-colors,
 complementary-color and analogous-colors of the System's color to configure your Wezterm's:
   - config.color_scheme
   - config.colors for:
     - window fg & bg
     - cursor
     - selection
     - scroll_bar thumb
     - split
     - launcher
   - config.integrated_title_button_color

Also, it provides you with a wezterm.GLOBAL.system table with the System's theme and color,
and the shades, tints, triadic-colors, complementary-color and analogous-colors of the System's
color. You can use this table to configure the color of other WezTerm features. You can see their
values in your WezTerm log file that is located in the `$XDG_RUNTIME_DIR/wezterm` directory.

**NOTE: This plugin only works on Ubuntu version>=24.04.**

## Installation and Usage

```lua
local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- Add these lines (to install and use the plugin):
local repo = "https://github.com/sunbearc22/sb_show_system_color.wezterm.git"
wezterm.plugin.require(repo).apply_to_config(config, {})

return config
```

## Update

Press <kbd>CTRL</kbd><kbd>SHIFT</kbd><kbd>L</kbd> and run `wezterm.plugin.update_all()`.

## Removal

1. Press <kbd>CTRL</kbd><kbd>SHIFT</kbd><kbd>L</kbd> and run `wezterm.plugin.list()`.
2. Delete the `"plugin_dir"` directory of this plugin.
