# DeepSeek UI · WindUI Build 80

Build 80 是 WindUI 1.6.65 的 DeepSeek 主题单文件库和原生控件示例，提供五个普通页签（首页、控件、脚本、外观、关于）。

## 直接运行

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/lIllIIlII/NEW/main/deepseek-ui/demo.lua"))()
```

只加载库：

```lua
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/lIllIIlII/NEW/main/deepseek-ui/main.lua"))()
```

`demo.lua` 会从执行器工作区读取 `main.lua`，兼容 `main.lua`、`Workspace/main.lua` 和 `Delta/Workspace/main.lua` 三种路径。

## 资源与远程加载

所有欢迎音频、背景图、顶栏横幅、贴纸和桌宠均存放在 [`assets/`](assets/) 并由 `main.lua` 在运行时从 GitHub Raw 加载；GitHub Raw 不可用时回退到 jsDelivr。二进制素材不嵌入 Lua 文件。

运行时为执行器的 `getcustomasset` 建立 `DeepSeekUI/v9_<文件名>` 缓存。首次使用会下载并缓存，后续启动直接复用相同版本缓存。资源清单包括：

- `bg_01.jpg`–`bg_15.jpg`：背景图
- `pet_01.png`–`pet_12.png`、`pet_extra_01.png`–`pet_extra_06.png`：桌宠和贴纸
- `art_01.jpg`–`art_10.jpg`：顶栏横幅
- `welcome_new.mp3`：欢迎音频
- `ds-logo-*`、`ds-lockup-*`、`open*.png`：界面图标

## Build 80 优化

- 窗口开合主动画约 0.48 秒，背景和辅助元素淡入淡出约 0.42 秒，并带取消和过期回调保护。
- 走马灯由单一状态表驱动；自动运行、队伍检查、方框和欢迎音频开关共用状态，开关改变后立即同步显示。
- 资源加载使用 GitHub 远程源和统一 `v9_` 缓存，不把二进制资源塞进 `main.lua`。

## 验证

库文件通过 Luau 编译；项目回归测试覆盖窗口生命周期、原生控件、字体、下拉框、通知、走马灯和视觉动画。
