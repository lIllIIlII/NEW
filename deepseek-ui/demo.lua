local BASE = "https://raw.githubusercontent.com/lIllIIlII/NEW/main/deepseek-ui/"

local WindUI = loadstring(game:HttpGet(BASE .. "main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "DeepSeek",
	Icon = "lucide:sparkles",
	Author = "DeepSeek AI",
	Folder = "DeepSeekUI",
	Size = UDim2.fromOffset(660, 470),
	MinSize = Vector2.new(560, 350),
	MaxSize = Vector2.new(850, 560),
	Transparent = false,
	Theme = nil,
	HideSearchBar = false,
	SideBarWidth = 200,
	User = {
		Enabled = true,
		Anonymous = false,
	},
})

local function Call(obj, name, props)
	if not obj then
		return nil
	end
	local fn = obj[name]
	if type(fn) ~= "function" then
		warn("[DeepSeekUI] missing element: " .. tostring(name))
		return nil
	end
	local ok, res = pcall(fn, obj, props)
	if not ok then
		warn("[DeepSeekUI] " .. tostring(name) .. " failed: " .. tostring(res))
		return nil
	end
	return res
end

local Home = Window:Tab({ Title = "Home", Icon = "lucide:house" })
local Scripts = Window:Tab({ Title = "Scripts", Icon = "lucide:code" })
local Interface = Window:Tab({ Title = "Interface", Icon = "lucide:sliders-horizontal" })
local About = Window:Tab({ Title = "About", Icon = "lucide:whale" })

Call(Home, "Section", { Title = "Overview" })

Call(Home, "Paragraph", {
	Title = "DeepSeek UI",
	Desc = "Square corners, DeepSeek blue palette, random whale wallpapers and a pet peeking from the left edge.",
})

Call(Home, "Button", {
	Title = "Say Hi",
	Desc = "Fire a notification",
	Callback = function()
		WindUI:Notify({
			Title = "DeepSeek",
			Content = "Hello from the whale.",
			Duration = 4,
		})
	end,
})

Call(Home, "Toggle", {
	Title = "Auto Run",
	Desc = "Run scripts on injection",
	Value = true,
	Callback = function(state)
		print("[DeepSeekUI] AutoRun =", state)
	end,
})

Call(Home, "Slider", {
	Title = "Speed",
	Desc = "",
	Value = { Min = 0, Max = 100, Default = 45 },
	Callback = function(value)
		print("[DeepSeekUI] Speed =", value)
	end,
})

Call(Home, "Dropdown", {
	Title = "Mode",
	Values = { "Balanced", "Aggressive", "Silent" },
	Value = "Balanced",
	Callback = function(value)
		print("[DeepSeekUI] Mode =", value)
	end,
})

Call(Home, "Input", {
	Title = "Nickname",
	Placeholder = "type something...",
	Value = "",
	Callback = function(text)
		print("[DeepSeekUI] Nickname =", text)
	end,
})

Call(Home, "Keybind", {
	Title = "Toggle Menu",
	Value = "K",
	Callback = function(key)
		print("[DeepSeekUI] Keybind =", key)
	end,
})

Call(Home, "Colorpicker", {
	Title = "Accent",
	Default = Color3.fromHex("#4D6BFE"),
	Callback = function(color)
		print("[DeepSeekUI] Accent =", color)
	end,
})

Call(Scripts, "Section", { Title = "Loaders" })

for _, item in ipairs({
	{ title = "Infinite Yield", desc = "Admin panel" },
	{ title = "ESP", desc = "Highlight all players" },
	{ title = "Auto Farm", desc = "Loop tasks" },
}) do
	Call(Scripts, "Button", {
		Title = item.title,
		Desc = item.desc,
		Callback = function()
			WindUI:Notify({
				Title = item.title,
				Content = "Started.",
				Duration = 3,
			})
		end,
	})
end

Call(Scripts, "Divider")

Call(Scripts, "Button", {
	Title = "Clear All",
	Desc = "Reset every toggle",
	Callback = function()
		WindUI:Notify({
			Title = "Cleared",
			Content = "All toggles reset.",
			Duration = 3,
		})
	end,
})

Call(Interface, "Section", { Title = "Appearance" })

Call(Interface, "Button", {
	Title = "Dark Theme",
	Desc = "#070B13 with DeepSeek blue",
	Callback = function()
		WindUI:SetTheme("Dark")
	end,
})

Call(Interface, "Button", {
	Title = "Light Theme",
	Desc = "#FFFFFF with DeepSeek blue",
	Callback = function()
		WindUI:SetTheme("Light")
	end,
})

Call(Interface, "Slider", {
	Title = "UI Scale",
	Value = { Min = 70, Max = 130, Default = 100 },
	Callback = function(value)
		Window:SetUIScale(value / 100)
	end,
})

Call(Interface, "Toggle", {
	Title = "Fullscreen",
	Value = false,
	Callback = function(state)
		Window:ToggleFullscreen(state)
	end,
})

Call(Interface, "Button", {
	Title = "Center Window",
	Desc = "",
	Callback = function()
		Window:SetToTheCenter()
	end,
})

Call(Interface, "Button", {
	Title = "Lock All",
	Desc = "",
	Callback = function()
		Window:LockAll()
	end,
})

Call(Interface, "Button", {
	Title = "Unlock All",
	Desc = "",
	Callback = function()
		Window:UnlockAll()
	end,
})

Call(About, "Section", { Title = "DeepSeek UI" })

Call(About, "Paragraph", {
	Title = "WindUI 1.6.65 fork",
	Desc = "Square corners, search above tabs, random wallpapers, edge pet on the left, sitter on top.",
})

Call(About, "Button", {
	Title = "Open Repo",
	Desc = "github.com/lIllIIlII/NEW",
	Callback = function()
		if setclipboard then
			setclipboard("https://github.com/lIllIIlII/NEW")
		end
		WindUI:Notify({
			Title = "Copied",
			Content = "https://github.com/lIllIIlII/NEW",
			Duration = 4,
		})
	end,
})

Call(About, "Button", {
	Title = "Switch Theme",
	Desc = "Random dark / light",
	Callback = function()
		WindUI:SetTheme(math.random(2) == 1 and "Dark" or "Light")
	end,
})

Window:OnClose(function()
	print("[DeepSeekUI] window closed")
end)

Window:OnOpen(function()
	print("[DeepSeekUI] window opened")
end)

Window:SelectTab(Home)

task.delay(0.6, function()
	WindUI:Notify({
		Title = "DeepSeek UI",
		Content = "Loaded. Search bar is above the tabs.",
		Duration = 5,
	})
end)
