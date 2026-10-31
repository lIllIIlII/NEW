# DeepSeek UI · WindUI 深度改版

基于 WindUI v1.6.65 的 DeepSeek 主题改版，全部直角、搜索栏置顶、蓝白/黑白随机配色、随机 DeepSeek 鲸鱼娘壁纸 + 边缘偷看桌宠 + 趴在窗口上的鲸鱼娘。

## 目录结构

```
main.lua          改版后的 WindUI 单文件（直接 loadstring 用）
assets/           图片资源（17 张壁纸/立绘/透明抠图）
```

## 一、先上传到你的 GitHub

在电脑上执行（把 `用户名` 换成你的 GitHub 用户名）：

```bash
# 1. 新建仓库 NEW（网页端建，Public，不要勾 README）
git clone https://github.com/用户名/NEW.git
cd NEW
# 把本目录的 main.lua 和 assets/ 整个拷进来
git add .
git commit -m "DeepSeek UI"
git push
```

## 二、改 CDN 地址

用编辑器打开 `main.lua`，搜索 `[GITHUB_USER]`，全部替换成你的 GitHub 用户名（共 2 处，同一个字符串）。

```lua
local DS_CDN={
"https://raw.githubusercontent.com/你的用户名/NEW/main/assets/",
"https://cdn.jsdelivr.net/gh/你的用户名/NEW@main/assets/",
}
```

第一条是 GitHub 直连，第二条是 jsDelivr 国内加速，脚本会按顺序回退，哪条能通用哪条。

## 三、使用

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/你的用户名/NEW/main/assets/../main.lua"))()
```

也可以直接 `loadstring(readfile("main.lua"))()`。

创建窗口：

```lua
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/你的用户名/NEW/main.lua"))()
local Window = WindUI:CreateWindow({
    Title="DeepSeek",
    Theme=nil,           -- 留空 = 每次启动随机 蓝黑夜 / 白昼
    HideSearchBar=false,
})
```

`Theme="Dark"` 强制蓝黑夜，`Theme="Light"` 强制白昼。

## 素材清单

`bg_01.jpg` 背景 · 彩色鲸鱼娘近景（随机）
`bg_02.jpg` 背景 · 黑白 DeepSeek 线稿（随机）
`pet_01.png` 桌宠 · 鲸鱼娘头部抠图
`pet_02.png` 桌宠 · Q 版鲸鱼娘全身抠图
`pet_03.png` 桌宠 · 像素风鲸鱼娘抠图
`pet_04.png` 桌宠 · DeepSeek 鲸鱼少女设定图抠图
`pet_05.png` 桌宠 · 女仆装 DeepSeek 鲸鱼娘立绘抠图（主用）
`art_01..07.jpg` 顶栏横幅 · 你提供的 7 张原图
`art_08.jpg` 顶栏横幅 · DeepSeek 鲸鱼少女设定
`art_09.jpg` 顶栏横幅 · 官方蓝白 DeepSeek 娘
`art_10.jpg` 顶栏横幅 · 青花瓷旗袍 DeepSeek 娘

## 改了什么

1. 全部圆角强制归零：`SetRadius` 里 `SliceScale=0`，`New` 里所有 `UICorner` 半径置 0，窗口、按钮、输入框、开关、滚动条一律直角。
2. 搜索栏下沉处理改为常驻显示并固定在分页栏上方（`HideSearchBar=false`），页签列表自动下移 45px 让位。
3. 配色整套换成 DeepSeek 蓝白：主色 `#4D6BFE`，暗色 `#070B13` / `#0C1220`，亮色 `#FFFFFF` / `#F3F7FF`，两套主题每次启动随机。
4. 窗口背景接随机 DeepSeek 壁纸（`ScaleType=Crop` + 纵向渐变遮罩，暗色透明 0.14、亮色 0.40），不压字。
5. 窗口左边缘外挂一张透明抠图鲸鱼娘，只露 100px 进窗口，带 2.4s 呼吸浮动，就是"在 UI 边缘偷看"。
6. 窗口顶边正中趴一只 Q 版鲸鱼娘，锚点 `(0.5,1)`、下沉 26px，看起来是趴在窗口横梁上。
7. 顶栏加随机鲸鱼娘横幅（左右渐变淡出）+ 1px DeepSeek 蓝分割线，窗口描 1px 蓝色边。
8. 图片加载全部走 `writefile` + `getcustomasset`，落地 `DeepSeekUI/` 目录，第二次启动直接读本地缓存不再下载。
9. 全文件零新增注释。
