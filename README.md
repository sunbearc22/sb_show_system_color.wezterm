# sb_show_system_color.wezterm

This plugin obtains Ubuntu >=24.04 system theme and color, and works out the shades, tints, triadic-colors, complementary-color and analogous-colors of the system's color to configure Wezterm's:
   - `config.color_scheme`
   - `config.colors` for:
     - window `fg` & `bg`
     - cursor
     - selection
     - scroll_bar thumb
     - split
     - launcher
   - `config.integrated_title_button_color`

Also, it provides you with a `wezterm.GLOBAL.system` table with the afore mentioned data under these field names: `theme`, `color`, `shades`, `tints`, `triadic`, `complementary`, `analogous`. You can use this table to configure the color of other WezTerm features. You can view their values in your WezTerm log file that is located in the `$XDG_RUNTIME_DIR/wezterm` directory and somtimes in WezTerm's log overlay by pressing <kbd>CTRL</kbd><kbd>SHIFT</kbd><kbd>L</kbd>. For example:
```
21:51:53.764 INFO logging > lua: [COLOR] wezterm.GLOBAL.system:- theme=Yaru-purple-dark, color=#7764d8
21:51:53.764 INFO logging > lua: [COLOR] wezterm.GLOBAL.system.shades  #7764d8 #6b5ac2 #5f50ac #534697 #473c81 #3b326c #2f2856 #231e40 #17142b #0b0a15 #000000
21:51:53.764 INFO logging > lua: [COLOR] wezterm.GLOBAL.system.tints  #7764d8 #8473db #9283df #9f92e3 #ada2e7 #bbb1eb #c8c1ef #d6d0f3 #e3e0f7 #f1effb #ffffff
21:51:53.764 INFO logging > lua: [COLOR] wezterm.GLOBAL.system.triadic  #7764d8 #d87764 #64d877
21:51:53.764 INFO logging > lua: [COLOR] wezterm.GLOBAL.system.complementary  #7764d8 #889b27
21:51:53.764 INFO logging > lua: [COLOR] wezterm.GLOBAL.system.analogous  #7764d8 #648bd8 #7764d8 #b164d8
````
**NOTE: This plugin should be required after requiring [sb_base.wezterm](https://github.com/sunbearc22/sb_base.wezterm.git) and before requiring any plugins/modules to configure the color of any WezTerm feature(s).**

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
