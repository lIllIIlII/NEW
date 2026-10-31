# DeepSeek UI · WindUI 深度改版

基于 WindUI v1.6.65 的 DeepSeek 主题改版：全部直角、搜索栏在分页栏上方、蓝白/黑白随机配色、随机鲸鱼娘壁纸、藏在窗口后的桌宠、趴在顶栏的鲸鱼娘、角落表情贴纸，全套入场动画。

仓库地址：https://github.com/lIllIIlII/NEW

## 目录

```
deepseek-ui/
├── main.lua        改版后的 WindUI 单文件（库源码）
├── demo.lua        UI 示例，直接跑这个
├── assets/         26 张图片（4 壁纸 + 12 桌宠 + 10 顶栏横幅）
├── preview_dark.png
└── preview_light.png
```

`main.lua` 只是 UI 库，单独跑没有画面，要看效果跑 `demo.lua`。

## 直接使用

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/lIllIIlII/NEW/main/deepseek-ui/demo.lua"))()
```

只要库：

```lua
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/lIllIIlII/NEW/main/deepseek-ui/main.lua"))()
```

国内慢就把 `raw.githubusercontent.com/lIllIIlII/NEW/main` 换成 `cdn.jsdelivr.net/gh/lIllIIlII/NEW@main`，图片加载内部也按这个顺序回退。

## 创建窗口

```lua
local Window = WindUI:CreateWindow({
    Title = "DeepSeek",
    Icon = "lucide:sparkles",
    Author = "DeepSeek AI",
    Folder = "DeepSeekUI",
    Size = UDim2.fromOffset(680, 480),
    Theme = nil,
    HideSearchBar = false,
    User = { Enabled = true, Anonymous = false },
})

Window:Tag({ Title = "v1.6.65", Icon = "lucide:badge-check" })
```

`Theme = "Dark"` 强制蓝黑夜，`Theme = "Light"` 强制蓝白昼，留空每次启动随机。

## 元素写法

```lua
local Tab = Window:Tab({ Title = "Home", Icon = "lucide:house" })

Tab:Section({ Title = "Overview" })
Tab:Paragraph({ Title = "标题", Desc = "说明" })
Tab:Button({ Title = "按钮", Desc = "说明", Callback = function() end })
Tab:Toggle({ Title = "开关", Value = true, Callback = function(s) end })
Tab:Slider({ Title = "滑条", Value = { Min = 0, Max = 100, Default = 45 }, Callback = function(v) end })
Tab:Dropdown({ Title = "下拉", Values = { "A", "B" }, Value = "A", Callback = function(v) end })
Tab:Dropdown({ Title = "多选", Values = { "X", "Y" }, Value = { "X" }, Multi = true, Callback = function(l) end })
Tab:Input({ Title = "输入", Placeholder = "...", Value = "", Callback = function(v) end })
Tab:Keybind({ Title = "按键", Value = "K", Callback = function(v) end })
Tab:Colorpicker({ Title = "颜色", Default = Color3.fromHex("#4D6BFE"), Callback = function(c) end })
Tab:Divider()
```

窗口方法：`SelectTab` `SetTitle` `SetAuthor` `SetSize` `SetUIScale` `ToggleFullscreen` `SetToTheCenter` `LockAll` `UnlockAll` `Open` `Close` `Toggle` `Destroy` `OnOpen` `OnClose` `OnDestroy` `Tag` `CreateTopbarButton`。

库方法：`Notify` `SetTheme` `GetThemes` `AddTheme` `SetLanguage` `ToggleAcrylic` `Dialog`。

## 素材

| 文件 | 用途 |
|---|---|
| `bg_01~04.jpg` | 横屏壁纸，随机轮换（发光 DeepSeek 娘 / 侧颜 / 眼部特写） |
| `pet_01~12.png` | 竖版表情抠图，桌宠 + 顶栏坐姿 + 角落贴纸三处共用随机池 |
| `art_01~10.jpg` | 顶栏横幅，横向渐变淡出 |

## 改了什么

1. 全部直角：`SetRadius` 里 `SliceScale = 0` 抹掉所有 NineSlice 圆角，`New` 里所有 `UICorner` 半径强制 `UDim.new(0, 0)`。
2. 搜索栏放到分页栏上方：`HideSearchBar = false` 常驻，页签列表自动下移 45px。
3. DeepSeek 配色：暗色 `#070B13` / `#0C1220`，亮色 `#FFFFFF` / `#F3F7FF`，主色 `#4D6BFE`，启动随机。
4. 随机背景：`ScaleType = Crop` 加纵向渐变遮罩（暗 0.38→0.76，亮 0.52→0.86），背景层留 28px 余量给动画。
5. 藏在窗口后面的桌宠：ZIndex 低于背景层，从左侧探出三分之二身子，2.6 秒呼吸浮动。
6. 顶栏坐姿鲸鱼娘：锚点 `(0.5, 1)` 下沉 22px，1.9 秒上下 8px。
7. 角落贴纸：原 resize 手柄透明化，同位放表情贴纸，可点击、可悬停、每 3.2 秒摇摆。
8. 拖动发光：拖动或缩放时 1px 蓝边亮成 2.4px、透明度压到 0.05，停手 0.55 秒回落。
9. 拖动换脸：拖动窗口时每 0.4 秒给角落贴纸换一张表情。
10. 入场动画：窗口 90% 弹回 100%，壁纸从全透明淡入，顶栏鲸鱼娘从上方掉入，桌宠从左侧滑入，贴纸从右侧滑入，全部错开 40ms。
11. 四角标记：窗口四个角各加 1px 蓝色 L 形角标，透明度 0.30，简约仪表感。
12. 抠图：逐像素局部容差漫水填充（浅色与蓝色系分开判定），0.9px 高斯羽化，反预乘去白边，最大连通域保留主体，白色围裙白帽子完整保留。
13. 加载优化：图片落地 `DeepSeekUI/` 目录，第二次启动直接读本地缓存。
14. 零注释：库文件和示例都没多写一行注释。
