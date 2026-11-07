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

资源按以下优先级解析：先检查 Roblox 原生资源 ID，再从 GitHub Raw 下载；Raw 不可用时回退到 jsDelivr。二进制素材不嵌入 Lua 文件。当前库内置已确认的 DeepSeek logo / lockup 原生 ID。背景图、桌宠、贴纸及欢迎音频如有已上传的 Roblox ID，可在运行前注入映射表：

```lua
_G.DS_NATIVE_ASSETS = {
    ["bg_01.jpg"] = "rbxassetid://1234567890",
    ["pet_extra_01.png"] = 2345678901,
    ["welcome_new.mp3"] = "rbxassetid://3456789012",
}
```

映射支持数字 ID 与 `rbxassetid://...` 字符串。未配置原生 ID 的资源自动从 GitHub 加载。GitHub 下载的文件会通过执行器 `getcustomasset` 接入，并缓存到 `DeepSeekUI/v9_<文件名>`；该缓存仅用于适配 `getcustomasset`，素材权威来源仍是远端。

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
