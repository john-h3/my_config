local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- --- 核心设置：禁用所有默认快捷键 ---
config.disable_default_key_bindings = true

-- --- 视觉与外观 ---
-- 选一个深受 Mac 用户喜爱的配色
config.color_scheme = 'Catppuccin Macchiato' 

-- 字体设置：Mac 必选 JetBrains Mono 或 SF Mono
-- 建议安装：brew install --cask font-jetbrains-mono-nerd-font
config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Medium' })
config.font_size = 13.0

config.initial_cols = 150
config.initial_rows = 40

-- 完美的 macOS 毛玻璃效果
config.window_background_opacity = 0.85
config.macos_window_background_blur = 30
-- 隐藏标题栏，让窗口看起来更像原生的 iTerm2 或简洁的编辑器
config.window_decorations = "RESIZE"

-- --- 窗口布局 ---
config.window_padding = {
  left = 15,
  right = 15,
  top = 15,
  bottom = 15,
}

-- --- 标签栏 (Tabs) ---
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false -- 标签放在顶部更符合习惯

-- --- 快捷键 (符合 Mac 习惯) ---
config.keys = {
  -- --- 修复 Option + 方向键：在单词间跳跃 ---
  -- Option + Left (向左跳一个词)
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1bb', -- 发送 Esc + b
  },
  -- Option + Right (向右跳一个词)
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1bf', -- 发送 Esc + f
  },
  -- 重新映射命令调色盘 (Command Palette)
  { 
    key = 'P', 
    mods = 'CMD|SHIFT', 
    action = wezterm.action.ActivateCommandPalette 
  },
  -- 按下 Cmd+Shift+S 后，屏幕会出现字母，按下对应字母即可跳到那个分屏
  { 
    key = 'S', 
    mods = 'CMD|SHIFT', 
    action = wezterm.action.PaneSelect { mode = 'Activate' } 
  },
  {
    key = 'l', 
    mods = 'CMD|SHIFT', 
    action = wezterm.action.ShowLauncherArgs { 
      -- 只显示你定义的 launch_menu 条目，去掉默认的 Shell 和 Tab 列表
      flags = 'LAUNCH_MENU_ITEMS' 
    } 
  },
  -- Cmd + Shift + N 创建一个新的独立窗口
  { 
    key = 'n', 
    mods = 'CMD|SHIFT', 
    action = wezterm.action.SpawnWindow 
  },

  -- 使用 Command + w 关闭当前分屏/标签
  { key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentPane { confirm = true } },
  -- 使用 Command + t 新建标签
  { key = 'n', mods = 'CMD', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'k', mods = 'CMD', action = wezterm.action.ClearScrollback 'ScrollbackAndViewport' },

  -- 强烈建议保留/手动定义以下基础快捷键，否则你会发现连退出都不行：
  { key = 'q', mods = 'CMD', action = wezterm.action.QuitApplication },
  { key = 'c', mods = 'CMD', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CMD', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'f', mods = 'CMD', action = wezterm.action.Search 'CurrentSelectionOrEmptyString' },
  { key = '=', mods = 'CMD', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CMD', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CMD', action = wezterm.action.ResetFontSize },
}

for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CMD',
    action = wezterm.action.ActivateTab(i - 1), -- 索引从 0 开始，所以要减 1
  })
end

-- 将 macOS 的 Option 键映射为 Alt 键
--config.send_composed_key_when_left_alt_is_pressed = true
--config.send_composed_key_when_right_alt_is_pressed = true

local function enroll_ssh_hosts()
  local hosts = {}
  local f = io.open(wezterm.home_dir .. "/.ssh/config", "r")
  if f then
    for line in f:lines() do
      -- 匹配 Host 后面跟着的名字，排除通配符 *
      local host = line:match("^Host%s+(%S+)")
      if host and host ~= "*" then
        table.insert(hosts, {
          label = 'SSH: ' .. host,
          args = { 'ssh', host },
        })
      end
    end
    f:close()
  end
  return hosts
end

-- 将读取到的主机应用到菜单
config.launch_menu = enroll_ssh_hosts()

return config
