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
		_G.DS_RegisterJump(props.Title, res, Group)
	end
	return res
end

local Group = "首页"

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
	Window:Tag({ Title = "DEEPSEEK" })
end)

local Home = Window:Tab({ Title = "首页", Icon = "lucide:house" })
local Controls = Window:Tab({ Title = "控件", Icon = "lucide:sliders-horizontal" })
local Scripts = Window:Tab({ Title = "脚本", Icon = "lucide:code" })
local Look = Window:Tab({ Title = "外观", Icon = "lucide:palette" })
local Info = Window:Tab({ Title = "关于", Icon = "lucide:whale" })

Call(Home, "Section", { Title = "总览" })
Call(Home, "Button", {
	Title = "功能跳转",
	Desc = "弹出功能索引，点一下直接飞过去（Jump）",
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
		tick("显示FOV", state)
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

Group = "控件"
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

Group = "脚本"
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

Group = "外观"
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
	end,
})
Call(Look, "Divider")
Call(Look, "Section", { Title = "文字大小" })
local _, curScale = 0.92, 0.92
if _G.DS_FontGet then
	local _
	_, curScale = _G.DS_FontGet()
end
Call(Look, "Slider", {
	Title = "字号大小",
	Desc = "缩放所有文字，字体保持系统默认",
	Value = { Min = 70, Max = 150, Default = math.floor(curScale * 100) },
	Callback = function(v)
		if _G.DS_SetFontScale then _G.DS_SetFontScale(v / 100) end
	end,
})
Call(Look, "Button", {
	Title = "恢复默认字号",
	Desc = "回到 100%",
	Callback = function()
		if _G.DS_SetFontScale then _G.DS_SetFontScale(1.0) end
	end,
})
Call(Look, "Divider")
Call(Look, "Section", { Title = "模块开关" })
for _, m in ipairs({
	{ k = "pet", t = "桌宠", d = "窗口左边探头的那只" },
	{ k = "sitter", t = "顶栏看板娘", d = "趴在顶栏上的那只" },
	{ k = "sticker", t = "角落贴纸", d = "右下角可以点的贴纸" },
	{ k = "ticker", t = "功能走马灯", d = "右上角的发光文字列" },
	{ k = "bg", t = "背景壁纸", d = "窗口里的随机鲸鱼壁纸" },
	{ k = "sheen", t = "扫光", d = "每几秒掠过窗口的光带" },
	{ k = "jag", t = "不规则边框", d = "锯齿状的边缘轮廓" },
	{ k = "glow", t = "拖动亮边", d = "拖动窗口时边框发光" },
	{ k = "sound", t = "加载音效", d = "界面出现时播放的声音" },
}) do
	Call(Look, "Toggle", {
		Title = m.t,
		Desc = m.d,
		Value = true,
		Callback = function(v)
			if _G.DS_Set then _G.DS_Set(m.k, v) end
		end,
	})
end
Call(Look, "Divider")
Call(Look, "Section", { Title = "功能索引" })
Call(Look, "Paragraph", {
	Title = "跳跃式定位",
	Desc = "点下面的按钮弹出功能索引面板，选中任意一项会滚动到那个控件，放大一点、描一圈蓝边，然后恢复。",
})
Call(Look, "Button", {
	Title = "打开功能索引",
	Desc = "浏览全部控件",
	Callback = function()
		if _G.DS_OpenJump then
			_G.DS_OpenJump()
		end
	end,
})
Call(Look, "Button", {
	Title = "手动登记一个入口",
	Desc = "演示 _G.DS_RegisterJump(name, 控件对象)",
	Callback = function()
		local obj = Call(Look, "Paragraph", {
			Title = "临时入口 " .. tostring(math.random(100, 999)),
			Desc = "这个控件是刚生成的，并且被手动登记进了索引。",
		})
		if obj and _G.DS_RegisterJump then
			_G.DS_RegisterJump("手动登记测试", obj)
		end
		notify("已登记", "打开功能索引看看最后一项。")
	end,
})
Call(Look, "Divider")
Call(Look, "Section", { Title = "窗口操作" })
Call(Look, "Button", { Title = "回到屏幕中心", Desc = "把窗口吸附到中间", Callback = function() Window:SetToTheCenter() end })
Call(Look, "Button", {
	Title = "彻底关闭（销毁界面）",
	Desc = "直接销毁整个界面，鱼也不会留下",
	Callback = function()
		if _G.DS_Close then
			_G.DS_Close()
		else
			Window:Close()
		end
	end,
})
Call(Look, "Button", { Title = "锁定全部", Desc = "冻结所有元素", Callback = function() Window:LockAll() end })
Call(Look, "Button", { Title = "解锁全部", Desc = "释放所有元素", Callback = function() Window:UnlockAll() end })
Call(Look, "Input", { Title = "窗口标题", Desc = "改掉左上角的字", Placeholder = "DeepSeek", Value = "DeepSeek", Callback = function(v) Window:SetTitle(v) end })
Call(Look, "Keybind", { Title = "显示 / 隐藏", Desc = "用快捷键开关窗口", Value = "RightControl", Callback = function(k) print("[开关]", k) end })

Group = "关于"
Call(Info, "Section", { Title = "DeepSeek UI" })
Call(Info, "Section", { Title = "标志" })
Call(Info, "Paragraph", {
	Title = "图片资源",
	Desc = "ds-lockup-blue / ds-lockup-black / ds-logo-blue / ds-logo-black，四张 256px 透明底图，已随库上传。",
})
Call(Info, "Section", { Title = "网络图片" })
Call(Info, "Paragraph", {
	Title = "免上传图源",
	Desc = "_G.DS_Img(url) 会下载任意 http(s) 图片并缓存成本地资源，返回可直接赋给 Image 的路径。不用一张张传 GitHub。",
})
Call(Info, "Button", {
	Title = "随机网络壁纸",
	Desc = "picsum.photos 随机图，直接铺到窗口背景",
	Callback = function()
		if not _G.DS_Img then return end
		local url = "https://picsum.photos/seed/" .. tostring(math.random(1, 99999)) .. "/1200/800"
		local id = _G.DS_Img(url)
		if id then
			pcall(function() Window:SetBackgroundImage(id) end)
			notify("壁纸已更换", "来源 picsum.photos")
		else
			notify("下载失败", "换个网络再试")
		end
	end,
})
Call(Info, "Button", {
	Title = "随机头像",
	Desc = "dicebear 生成的矢量头像 PNG",
	Callback = function()
		if not _G.DS_Img then return end
		local url = "https://api.dicebear.com/9.x/bottts/png?seed=" .. tostring(math.random(1, 99999)) .. "&size=256"
		local id = _G.DS_Img(url)
		notify("头像", id and "已缓存" or "下载失败")
	end,
})
Call(Info, "Paragraph", {
	Title = "图片资源",
	Desc = "ds-lockup-blue / ds-lockup-black / ds-logo-blue / ds-logo-black，四张 256px 透明底图，已随库上传。",
})
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
	Title = "播放加载音效",
	Desc = "重新播放启动音",
	Callback = function()
		if _G.DS_PlaySound then _G.DS_PlaySound(0.6) end
	end,
})
Call(Info, "Button", {
	Title = "停止音效",
	Desc = "关掉正在播的声音",
	Callback = function()
		if _G.DS_StopSound then _G.DS_StopSound() end
	end,
})
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
		_G.DS_Ticker.Set({ "显示FOV", "队伍检测", "透视方框", "自动运行", "打击特效", "光环动画" })
	end
	notify("DeepSeek UI", "加载完成。搜索栏在标签栏上方。")
end)

local Index = Window:Tab({ Title = "索引", Icon = "lucide:list" })

Group = "索引"
Call(Index, "Section", { Title = "功能定位" })
Call(Index, "Paragraph", {
	Title = "跳转到任意控件",
	Desc = "选中一项后会先切到它所在的页，再滚动过去，轻微放大并描一圈高亮，然后恢复。",
})
Call(Index, "Dropdown", {
	Title = "选择功能",
	Desc = "全部已登记控件",
	Values = (_G.DS_JumpNames and _G.DS_JumpNames()) or { "暂无" },
	Callback = function(v)
		if _G.DS_JumpToName then _G.DS_JumpToName(v) end
	end,
})
Call(Index, "Button", {
	Title = "悬浮索引",
	Desc = "在窗口左上角弹出下拉列表",
	Callback = function()
		if _G.DS_OpenJump then _G.DS_OpenJump() end
	end,
})
Call(Index, "Button", {
	Title = "登记当前入口",
	Desc = "演示 _G.DS_RegisterJump(name, 控件对象)",
	Callback = function()
		local obj = Call(Index, "Paragraph", {
			Title = "临时入口 " .. tostring(math.random(100, 999)),
			Desc = "刚生成并手动登记进索引的控件。",
		})
		if obj and _G.DS_RegisterJump then
			_G.DS_RegisterJump("手动登记测试", obj)
		end
		notify("已登记", "重新打开下拉列表就能看到最后一项。")
	end,
})
