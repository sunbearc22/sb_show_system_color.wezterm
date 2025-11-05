--[[
This Plugin does the following:
1. Initialize a wezterm.GLOBAL.system table with default value for:
    theme, color, shades, tints, triadic, complementary and analogous
  - These default values serve as fallback values.
  - Fields "theme" and "color" stores the system theme and color.
  - The next five fields are derived from "color" using functions in func_c.lua.
2. Obtain the System's theme and color via a custom python script that works only
   for Ubuntu>=24.04.
3. Update all the fields of wezterm.GLOBAL.system and use it to configure:
   - config.color_scheme
   - config.colors for:
     - window fg & bg
     - cursor
     - selection
     - scroll_bar thumb
     - split
     - launcher
   - config.integrated_title_button_color

Written by: sunbearc22
Tested on: Ubuntu 24.04.3, wezterm 20251025-070338-b6e75fd7
]]
local M = {}

local wezterm = require("wezterm")

---@param repo string?
local function find_plugin_package_path(repo)
  if not repo then
    return nil
  end

  local separator = package.config:sub(1, 1) == "\\" and "\\" or "/"

  for _, v in ipairs(wezterm.plugin.list()) do
    -- wezterm.log_info("[COLOR] " .. v.url)
    if v.url == repo then
      -- wezterm.log_info("[COLOR] v.url == repo")
      return v.plugin_dir .. separator .. 'plugin' .. separator .. '?.lua'
    end
  end

  -- Handle case where plugin is not found
  wezterm.log_error("[COLOR] Plugin not found: " .. repo)
  return nil
end

-- Find plugin path
local plugin = "https://github.com/sunbearc22/sb_show_system_color.wezterm.git"
local ppath = find_plugin_package_path(plugin)
-- wezterm.log_info("[COLOR] ppath = " .. ppath)

-- Exit if plugin is no found
if not ppath then return end

-- Get plugin's parent directory (used to access other non Lua files that belongs to this plugin)
local ppath_parent = string.gsub(ppath, "%?%.lua$", "")
-- wezterm.log_info("[COLOR] ppath_parent = " .. ppath_parent)

-- Update package.path (This ensures files mentioned in require() can be located)
package.path = package.path .. ";" .. ppath
-- wezterm.log_info("[COLOR] package.path = " .. package.path)

local func_c = require("func_c")

---@param config unknown
---@param opts {}
-- Module Function to apply to config
function M.apply_to_config(config, opts)
  local nshades = 10
  local ntints = 10
  local nanalogous = 3

  -- Local Function to update wezterm.GLOBAL.system table with Ubuntu >=24.04
  -- theme, color, shades, tints, triadic, complementary and analogous colors
  local function update_GLOBAL_system_theme_color()
    -- Default state of wezterm.GLOBAL.system table
    if not wezterm.GLOBAL.system then
      wezterm.GLOBAL.system = {
        theme = "Yaru-purple-dark",
        color = "#7764d8",
        shades = func_c.get_shades_of("#7764d8", nshades),
        tints = func_c.get_tints_of("#7764d8", ntints),
        triadic = func_c.get_triadic_colors_of("#7764d8"),
        complementary = func_c.get_complementary_color_of("#7764d8"),
        analogous = func_c.get_analogous_colors_of("#7764d8", nanalogous),
      }
    end

    -- Use custom python script to get Ubuntu >=24.04 theme and color
    local pyscript = ppath_parent .. "get_ubuntu_24.04_theme_color.py"
    -- wezterm.log_info("[COLOR] pyscript = " .. pyscript)
    local success, stdout, stderr = wezterm.run_child_process({ "python3", pyscript })

    -- What to do when python script fails
    if not success then
      wezterm.log_errot("[COLOR] Failed to run Python script: " .. tostring(stderr))
    end

    -- Split stdout into individual lines, removes leading and trailing
    -- whitespace from each line, filter out empty lines and store data
    -- as an array
    local lines = {}
    for line in stdout:gmatch("[^\r\n]+") do
      line = line:match("^%s*(.-)%s*$")
      if line ~= "" then
        table.insert(lines, line)
      end
    end

    -- Update GLOBAL.system table with Ubuntu's theme, color, shades, tints,
    -- triadic, complementary and analogius colors
    if #lines == 2 then
      wezterm.GLOBAL.system.theme = lines[1]
      wezterm.GLOBAL.system.color = string.lower(lines[2])
      local ucolor = wezterm.GLOBAL.system.color
      wezterm.GLOBAL.system.shades = func_c.get_shades_of(ucolor, nshades)
      wezterm.GLOBAL.system.tints = func_c.get_tints_of(ucolor, ntints)
      wezterm.GLOBAL.system.triadic = func_c.get_triadic_colors_of(ucolor)
      wezterm.GLOBAL.system.complementary = func_c.get_complementary_color_of(ucolor)
      wezterm.GLOBAL.system.analogous = func_c.get_analogous_colors_of(ucolor, nanalogous)
    else
      wezterm.log_errot("[COLOR] Expected exactly 2 lines from Python script, got " .. #lines)
    end

    -- Debug: Print all values
    wezterm.log_info(
      "[COLOR] wezterm.GLOBAL.system:- theme=" .. wezterm.GLOBAL.system.theme
      .. ", color=" .. wezterm.GLOBAL.system.color
    )

    local function string_hexcodes(icolors)
      local cc = ""
      for _, c in ipairs(icolors) do
        cc = cc .. " " .. c
      end
      return cc
    end

    wezterm.log_info("[COLOR] wezterm.GLOBAL.system.shades " .. string_hexcodes(wezterm.GLOBAL.system.shades))
    wezterm.log_info("[COLOR] wezterm.GLOBAL.system.tints " .. string_hexcodes(wezterm.GLOBAL.system.tints))
    wezterm.log_info("[COLOR] wezterm.GLOBAL.system.triadic " .. string_hexcodes(wezterm.GLOBAL.system.triadic))
    wezterm.log_info("[COLOR] wezterm.GLOBAL.system.complementary " ..
      string_hexcodes(wezterm.GLOBAL.system.complementary))
    wezterm.log_info("[COLOR] wezterm.GLOBAL.system.analogous " .. string_hexcodes(wezterm.GLOBAL.system.analogous))
  end

  -- Local Function returns a color scheme for a given system theme
  local function get_color_scheme_for(theme)
    if string.lower(theme):find("dark") then
      return "Catppuccin Mocha"
    else
      return "Catppuccin Latte"
    end
  end

  -- Configure colors
  update_GLOBAL_system_theme_color()
  config.color_scheme = get_color_scheme_for(wezterm.GLOBAL.system.theme)
  config.colors = {
    foreground = wezterm.GLOBAL.system.tints[5],   -- The default text color
    background = wezterm.GLOBAL.system.shades[10], -- The default background color
    cursor_bg = wezterm.GLOBAL.system.color,
    cursor_fg = wezterm.GLOBAL.system.triadic[3],
    cursor_border = wezterm.GLOBAL.system.shades[8],
    compose_cursor = "gold",
    selection_fg = wezterm.GLOBAL.system.complementary[2],
    selection_bg = wezterm.GLOBAL.system.shades[9],
    scrollbar_thumb = wezterm.GLOBAL.system.color,
    split = wezterm.GLOBAL.system.shades[6],
    launcher_label_bg = { AnsiColor = "Black" },                      -- (*Since: Nightly Builds Only*)
    launcher_label_fg = { Color = wezterm.GLOBAL.system.triadic[2] }, -- (*Since: Nightly Builds Only*)
  }
  config.integrated_title_button_color = wezterm.GLOBAL.system.color
end

return M
