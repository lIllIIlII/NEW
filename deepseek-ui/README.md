# DeepSeek UI · WindUI 深度改版

基于 WindUI v1.6.65 的 DeepSeek 主题改版：全部直角、搜索栏在分页栏上方、蓝白/黑白随机配色、随机 DeepSeek 鲸鱼娘壁纸、左边缘偷看的桌宠、趴在窗口上的鲸鱼娘。

仓库地址：https://github.com/lIllIIlII/NEW

## 目录

```
deepseek-ui/
├── main.lua        改版后的 WindUI 单文件（库源码）
├── demo.lua        UI 示例，直接跑这个
├── assets/         34 张图片（壁纸 / 立绘 / 透明抠图 / 顶栏横幅 / 17 张表情贴纸）
├── preview_dark.png
└── preview_light.png
```

`main.lua` 只是 UI 库，单独跑没有画面，要看效果跑 `demo.lua`。

## 直接使用

```lua
local BASE = "https://raw.githubusercontent.com/lIllIIlII/NEW/main/deepseek-ui/"
loadstring(game:HttpGet(BASE .. "demo.lua"))()
```

只要库：

```lua
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/lIllIIlII/NEW/main/deepseek-ui/main.lua"))()
```

国内网络慢就把 `raw.githubusercontent.com/lIllIIlII/NEW/main` 换成 `cdn.jsdelivr.net/gh/lIllIIlII/NEW@main`，脚本内部图片加载也是按这个顺序自动回退的。

## 创建窗口

```lua
local Window = WindUI:CreateWindow({
    Title = "DeepSeek",
    Icon = "lucide:sparkles",
    Author = "DeepSeek AI",
    Folder = "DeepSeekUI",
    Size = UDim2.fromOffset(660, 470),
    Theme = nil,
    HideSearchBar = false,
    User = { Enabled = true, Anonymous = false },
})
```

`Theme = "Dark"` 强制蓝黑夜，`Theme = "Light"` 强制蓝白昼，留空则每次启动随机。

## 元素写法

```lua
local Tab = Window:Tab({ Title = "Home", Icon = "lucide:house" })

Tab:Section({ Title = "Overview" })
Tab:Paragraph({ Title = "标题", Desc = "说明" })
Tab:Button({ Title = "按钮", Desc = "说明", Callback = function() end })
Tab:Toggle({ Title = "开关", Value = true, Callback = function(state) end })
Tab:Slider({ Title = "滑条", Value = { Min = 0, Max = 100, Default = 45 }, Callback = function(v) end })
Tab:Dropdown({ Title = "下拉", Values = { "A", "B" }, Value = "A", Callback = function(v) end })
Tab:Input({ Title = "输入", Placeholder = "...", Value = "", Callback = function(v) end })
Tab:Keybind({ Title = "按键", Value = "K", Callback = function(v) end })
Tab:Colorpicker({ Title = "颜色", Default = Color3.fromHex("#4D6BFE"), Callback = function(c) end })
Tab:Divider()
```

窗口方法：`Window:SelectTab`、`Window:SetTitle`、`Window:SetAuthor`、`Window:SetSize`、`Window:SetUIScale`、`Window:ToggleFullscreen`、`Window:SetToTheCenter`、`Window:LockAll`、`Window:UnlockAll`、`Window:Open`、`Window:Close`、`Window:Toggle`、`Window:Destroy`、`Window:OnOpen`、`Window:OnClose`、`Window:OnDestroy`、`Window:CreateTopbarButton`。

库方法：`WindUI:Notify`、`WindUI:SetTheme`、`WindUI:GetThemes`、`WindUI:AddTheme`、`WindUI:SetLanguage`、`WindUI:ToggleAcrylic`、`WindUI:Dialog`。

## 素材

| 文件 | 用途 |
|---|---|
| `bg_01.jpg` | 背景 · 彩色鲸鱼娘近景（随机） |
| `bg_02.jpg` | 背景 · 黑白 DeepSeek 线稿（随机） |
| `pet_01.png` | 桌宠 · 鲸鱼娘头部抠图 |
| `pet_02.png` | 桌宠 · Q 版鲸鱼娘全身抠图 |
| `pet_03.png` | 桌宠 · 像素风鲸鱼娘抠图 |
| `pet_04.png` | 桌宠 · DeepSeek 鲸鱼少女设定图抠图 |
| `pet_05.png` | 桌宠 · 女仆装 DeepSeek 鲸鱼娘立绘抠图（主用） |
| `art_01~07.jpg` | 顶栏横幅 · 原始 7 张 |
| `art_08.jpg` | 顶栏横幅 · DeepSeek 鲸鱼少女设定 |
| `art_09.jpg` | 顶栏横幅 · 官方蓝白 DeepSeek 娘 |
| `art_10.jpg` | 顶栏横幅 · 青花瓷旗袍 DeepSeek 娘 |
| `stiker_01~17.png` | 表情贴纸 · 害羞/睡觉/问号/呜呜/棒/开心/哼/爱你/酷/辛苦了/好困/好耶 等，右下角挂件 + 拖窗口时随机换 |

## 改了什么

1. 全部直角：`SetRadius` 里 `SliceScale = 0` 抹掉所有 NineSlice 圆角，`New` 里所有 `UICorner` 半径强制 `UDim.new(0, 0)`，窗口、按钮、输入框、开关、滚动条、下拉全部方角。
2. 搜索栏放到分页栏上方：`HideSearchBar = false` 常驻，页签列表自动下移 45px 让位。
3. DeepSeek 配色：暗色 `#070B13` / `#0C1220`，亮色 `#FFFFFF` / `#F3F7FF`，主色统一 `#4D6BFE`，启动时 `math.random(2)` 随机挑一套。
4. 随机背景：`ScaleType = Crop` 加纵向渐变遮罩（暗色 0.38 到 0.76，亮色 0.52 到 0.86），壁纸有氛围又不压字。
5. 边缘偷看桌宠：**放在窗口图层下面**（ZIndex 低于背景），从窗口左边缘探出三分之二身子，被窗口遮住一部分，负 3 度倾斜，2.6 秒呼吸浮动，尺寸 214px。
6. 趴在 UI 上：顶边中央，锚点 `(0.5, 1)`，下沉 22px，看起来是坐在窗口横梁上。
7. 顶栏横幅：随机鲸鱼娘横向渐变淡出加 1px DeepSeek 蓝分割线，窗口描 1px 蓝边。
8. 加载优化：图片落地 `DeepSeekUI/` 目录，第二次启动直接读本地缓存，不再重复下载。
9. 右下角手柄换成贴纸：原斜箭头设为透明、`Active=false`，原位放一只小鲸鱼娘贴纸，可点击、可悬停。
10. SelectTab 崩溃修复：`Window:SelectTab` 现在同时接受页签对象和页签键，找不到就静默跳过，不再报 `attempt to index nil with 'Locked'`。
11. 动效：拖动窗口时 1px 蓝边瞬间亮成 2.4px 高亮发光，0.55 秒回落；拖动/缩放时右下角贴纸每 0.4 秒换一张脸；贴纸点击放大回弹并换图，悬停放大；每 3.2 秒轻微摇摆；顶部鲸鱼娘 1.9 秒上下浮动；左侧桌宠 2.6 秒呼吸浮动；窗口打开时从 94% 缩放回弹到 100%。
12. 抠图重做：改用逐像素局部容差漫水填充（浅色 + 蓝色系判定分开），边缘 0.9px 高斯羽化，白色去污反预乘，最大化连通域保留主体，白色围裙和白帽子都完整保留，背景干干净净。
13. 零注释：库文件和示例都没多写一行注释。
