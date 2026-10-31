local BASE = "https://raw.githubusercontent.com/lIllIIlII/NEW/main/deepseek-ui/"

local WindUI = loadstring(game:HttpGet(BASE .. "main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "DeepSeek",
	Icon = "lucide:sparkles",
	Author = "深度求索 AI",
	Folder = "DeepSeekUI",
	Size = UDim2.fromOffset(680, 480),
	MinSize = Vector2.new(560, 360),
	MaxSize = Vector2.new(880, 600),
	Transparent = false,
	Theme = nil,
	HideSearchBar = false,
	ScrollBarEnabled = false,
	SideBarWidth = 200,
	Acrylic = false,
	User = { Enabled = true, Anonymous = false },
})

local function Call(obj, name, props)
	if not obj then
		warn("[DeepSeekUI] 标签页为空: " .. tostring(name))
		return nil
	end
	local fn = obj[name]
	if type(fn) ~= "function" then
		warn("[DeepSeekUI] 缺少控件: " .. tostring(name))
		return nil
	end
	local ok, res = pcall(fn, obj, props)
	if not ok then
		warn("[DeepSeekUI] " .. tostring(name) .. " 出错: " .. tostring(res))
		return nil
	end
	if res and props and props.Title and _G.DS_RegisterJump then
		_G.DS_RegisterJump(props.Title, res)
	end
	return res
end

local function notify(title, content)
	WindUI:Notify({ Title = title, Content = content, Duration = 4 })
end

local function tick(name, on)
	if not _G.DS_Ticker then return end
	if on then
		_G.DS_Ticker.Add(name)
	else
		_G.DS_Ticker.Remove(name)
	end
end

Window:CreateTopbarButton("关于", "info", function()
	notify("DeepSeek UI", "WindUI 1.6.65 · 不规则轮廓 · 37 款字体 · 随机鲸鱼娘")
end, 24, nil, Color3.fromHex("#4D6BFE"))

Window:CreateTopbarButton("跳转", "search", function()
	if _G.DS_OpenJump then
		_G.DS_OpenJump()
	end
end, 24, nil, Color3.fromHex("#4D6BFE"))

pcall(function()
	Window:Tag({ Title = "v1.6.65", Icon = "lucide:badge-check" })
end)

local Home = Window:Tab({ Title = "首页", Icon = "lucide:house" })
local Controls = Window:Tab({ Title = "控件", Icon = "lucide:sliders-horizontal" })
local Scripts = Window:Tab({ Title = "脚本", Icon = "lucide:code" })
local Look = Window:Tab({ Title = "外观", Icon = "lucide:palette" })
local Info = Window:Tab({ Title = "关于", Icon = "lucide:whale" })

Call(Home, "Section", { Title = "总览" })
Call(Home, "Button", {
	Title = "功能跳转",
	Desc = "弹出功能索引，点一下直接飞过去",
	Callback = function()
		if _G.DS_OpenJump then
			_G.DS_OpenJump()
		end
	end,
})
Call(Home, "Paragraph", {
	Title = "DeepSeek 主题界面",
	Desc = "深海蓝配色、随机鲸鱼娘壁纸、左侧探头的小家伙、顶栏趴着的看板娘、右下角可以点的贴纸。拖动窗口时边框会亮起来。",
})
Call(Home, "Button", {
	Title = "发一条通知",
	Desc = "右上角弹出提示",
	Callback = function()
		notify("DeepSeek", "来自鲸鱼娘的问候。")
	end,
})
Call(Home, "Button", {
	Title = "打开对话框",
	Desc = "带两个按钮的模态窗",
	Callback = function()
		Window:Dialog({
			Title = "确认操作",
			Content = "现在就要运行选中的脚本吗？",
			Buttons = {
				{ Title = "取消", Callback = function() end, Variant = "Secondary" },
				{ Title = "运行", Callback = function() notify("已启动", "脚本开始执行。") end, Variant = "Primary" },
			},
		})
	end,
})
Call(Home, "Divider")
Call(Home, "Toggle", {
	Title = "自动运行",
	Desc = "注入后立刻执行",
	Value = true,
	Callback = function(state)
		print("[自动运行]", state)
		tick("自动运行", state)
	end,
})
Call(Home, "Slider", {
	Title = "移动速度",
	Desc = "角色行走速度",
	Value = { Min = 16, Max = 300, Default = 32 },
	Callback = function(v) print("[速度]", v) end,
})
Call(Home, "Dropdown", {
	Title = "目标模式",
	Desc = "脚本锁定的目标",
	Values = { "距离最近", "血量最低", "血量最高", "随机" },
	Value = "距离最近",
	Callback = function(v) print("[目标]", v) end,
})
Call(Home, "Input", {
	Title = "玩家名称",
	Desc = "把某个玩家加入白名单",
	Placeholder = "输入玩家名...",
	Value = "",
	Callback = function(v) print("[名称]", v) end,
})
Call(Home, "Keybind", {
	Title = "呼出菜单",
	Desc = "打开或关闭窗口",
	Value = "K",
	Callback = function(k) print("[快捷键]", k) end,
})
Call(Home, "Colorpicker", {
	Title = "主题色",
	Desc = "高亮颜色",
	Default = Color3.fromHex("#4D6BFE"),
	Callback = function(c) print("[主题色]", c) end,
})

Call(Controls, "Section", { Title = "多选" })
Call(Controls, "Dropdown", {
	Title = "功能开关",
	Desc = "可以同时选中多项",
	Values = { "透视", "自瞄", "飞行", "加速", "穿墙", "传送" },
	Value = { "透视", "加速" },
	Multi = true,
	Callback = function(list)
		print("[功能]", table.concat(list, "、"))
	end,
})
Call(Controls, "Section", { Title = "数值" })
Call(Controls, "Slider", {
	Title = "视野范围",
	Desc = "摄像机视场角",
	Value = { Min = 40, Max = 120, Default = 70 },
	Callback = function(v) print("[视野]", v) end,
})
Call(Controls, "Slider", {
	Title = "音量",
	Desc = "声音大小",
	Value = { Min = 0, Max = 100, Default = 50 },
	Callback = function(v) print("[音量]", v) end,
})
Call(Controls, "Divider")
Call(Controls, "Section", { Title = "开关" })
Call(Controls, "Toggle", {
	Title = "透视方框",
	Desc = "在所有玩家身上画方框",
	Value = false,
	Callback = function(v)
		print("[透视]", v)
		tick("透视方框", v)
	end,
})
Call(Controls, "Toggle", {
	Title = "队伍检测",
	Desc = "忽略自己的队友",
	Value = true,
	Callback = function(v)
		print("[队伍检测]", v)
		tick("队伍检测", v)
	end,
})
Call(Controls, "Toggle", {
	Title = "静默瞄准",
	Desc = "改变子弹飞行方向",
	Value = false,
	Callback = function(v)
		print("[静默瞄准]", v)
		tick("静默瞄准", v)
	end,
})
Call(Controls, "Input", {
	Title = "自定义前缀",
	Desc = "聊天指令的前缀符号",
	Placeholder = "；",
	Value = ";",
	Callback = function(v) print("[前缀]", v) end,
})
Call(Controls, "Keybind", {
	Title = "紧急停止键",
	Desc = "一键重置全部功能",
	Value = "RightShift",
	Callback = function(k) print("[紧急停止]", k) end,
})

Call(Scripts, "Section", { Title = "脚本中心" })
for _, item in ipairs({
	{ title = "无限收益", desc = "管理员面板", tag = "管理" },
	{ title = "透视套件", desc = "高亮所有玩家", tag = "视觉" },
	{ title = "自动刷取", desc = "循环挂机", tag = "挂机" },
	{ title = "传送中心", desc = "按坐标传送", tag = "移动" },
}) do
	Call(Scripts, "Button", {
		Title = item.title,
		Desc = item.desc,
		Callback = function()
			notify(item.title, "已加载（" .. item.tag .. "）")
		end,
	})
end
Call(Scripts, "Divider")
Call(Scripts, "Paragraph", {
	Title = "提示",
	Desc = "这里的按钮只会弹一条通知。要接真实功能，把执行代码写进 Callback 字段就行。",
})
Call(Scripts, "Button", {
	Title = "全部清除",
	Desc = "把所有开关恢复默认",
	Callback = function()
		notify("已清除", "所有开关都已重置。")
	end,
})

Call(Look, "Section", { Title = "主题配色" })
Call(Look, "Button", {
	Title = "深色",
	Desc = "#070B13 配深海蓝",
	Callback = function() WindUI:SetTheme("Dark") end,
})
Call(Look, "Button", {
	Title = "浅色",
	Desc = "#FFFFFF 配深海蓝",
	Callback = function() WindUI:SetTheme("Light") end,
})
Call(Look, "Button", {
	Title = "随机",
	Desc = "随机挑一套配色",
	Callback = function() WindUI:SetTheme(math.random(2) == 1 and "Dark" or "Light") end,
})
Call(Look, "Slider", {
	Title = "界面缩放",
	Desc = "整体放大缩小",
	Value = { Min = 70, Max = 130, Default = 100 },
	Callback = function(v) Window:SetUIScale(v / 100) end,
})
Call(Look, "Toggle", {
	Title = "全屏模式",
	Desc = "铺满整个屏幕",
	Value = false,
	Callback = function(v)
		Window:ToggleFullscreen(v)
		tick("全屏", v)
	end,
})
Call(Look, "Divider")
Call(Look, "Section", { Title = "字体" })
local FONTS = _G.DS_FontList or { "Arcade", "Code", "SciFi" }
local curFont, curScale = "Arcade", 0.92
if _G.DS_FontGet then
	curFont, curScale = _G.DS_FontGet()
end
Call(Look, "Dropdown", {
	Title = "字体样式",
	Desc = "Roblox 内置字体，37 款",
	Values = FONTS,
	Value = curFont,
	Callback = function(v)
		if _G.DS_SetFont then _G.DS_SetFont(v) end
		notify("字体已切换", tostring(v))
	end,
})
Call(Look, "Slider", {
	Title = "字号大小",
	Desc = "缩放所有文字",
	Value = { Min = 70, Max = 150, Default = math.floor(curScale * 100) },
	Callback = function(v)
		if _G.DS_SetFontScale then _G.DS_SetFontScale(v / 100) end
	end,
})
Call(Look, "Button", {
	Title = "恢复像素字体",
	Desc = "回到 Arcade 街机字",
	Callback = function()
		if _G.DS_SetFont then _G.DS_SetFont("Arcade") end
		if _G.DS_SetFontScale then _G.DS_SetFontScale(0.92) end
	end,
})
Call(Look, "Button", {
	Title = "重新应用字体",
	Desc = "把当前字体刷到每个控件",
	Callback = function()
		if _G.DS_ApplyFont then _G.DS_ApplyFont() end
	end,
})
Call(Look, "Divider")
Call(Look, "Section", { Title = "窗口操作" })
Call(Look, "Button", { Title = "回到屏幕中心", Desc = "把窗口吸附到中间", Callback = function() Window:SetToTheCenter() end })
Call(Look, "Button", { Title = "锁定全部", Desc = "冻结所有元素", Callback = function() Window:LockAll() end })
Call(Look, "Button", { Title = "解锁全部", Desc = "释放所有元素", Callback = function() Window:UnlockAll() end })
Call(Look, "Input", { Title = "窗口标题", Desc = "改掉左上角的字", Placeholder = "DeepSeek", Value = "DeepSeek", Callback = function(v) Window:SetTitle(v) end })
Call(Look, "Keybind", { Title = "显示 / 隐藏", Desc = "用快捷键开关窗口", Value = "RightControl", Callback = function(k) print("[开关]", k) end })

Call(Info, "Section", { Title = "DeepSeek UI" })
Call(Info, "Paragraph", {
	Title = "WindUI 1.6.65 改版",
	Desc = "圆角控件、搜索栏放在标签栏上方、深海蓝配色、随机鲸鱼娘壁纸、左侧探头的桌宠、顶栏看板娘、右下角可点贴纸、37 款内置字体。",
})
Call(Info, "Paragraph", {
	Title = "素材来源",
	Desc = "GitHub 上的 35 个文件：5 张壁纸、12 张立绘、10 张横幅、8 张表情贴纸。",
})
Call(Info, "Divider")
Call(Info, "Button", {
	Title = "复制仓库地址",
	Desc = "github.com/lIllIIlII/NEW",
	Callback = function()
		if setclipboard then setclipboard("https://github.com/lIllIIlII/NEW") end
		notify("已复制", "https://github.com/lIllIIlII/NEW")
	end,
})
Call(Info, "Button", {
	Title = "重新下载素材",
	Desc = "清掉本地缓存",
	Callback = function()
		if delfolder and isfolder and isfolder("DeepSeekUI") then pcall(delfolder, "DeepSeekUI") end
		notify("缓存已清", "重新加入游戏就会重新下载。")
	end,
})
Call(Info, "Toggle", {
	Title = "调试模式",
	Desc = "把控件报错打印出来",
	Value = false,
	Callback = function(v)
		if Window.Window then Window.Window.Debug = v end
		WindUI.Debug = v
	end,
})

Window:OnOpen(function() print("[DeepSeekUI] 窗口已打开") end)
Window:OnClose(function() print("[DeepSeekUI] 窗口已关闭") end)

Window:SelectTab(Home)

task.delay(0.6, function()
	if _G.DS_Ticker then
		_G.DS_Ticker.Set({ "自动运行", "队伍检测" })
	end
	notify("DeepSeek UI", "加载完成。搜索栏在标签栏上方。")
end)
