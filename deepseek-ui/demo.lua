local BASE = "https://raw.githubusercontent.com/lIllIIlII/NEW/main/deepseek-ui/"

local WindUI = loadstring(game:HttpGet(BASE .. "main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "DeepSeek",
	Icon = "lucide:sparkles",
	Author = "DeepSeek AI",
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
		warn("[DeepSeekUI] tab is nil for " .. tostring(name))
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

local function notify(title, content)
	WindUI:Notify({ Title = title, Content = content, Duration = 4 })
end

Window:CreateTopbarButton("Info", "info", function()
	notify("DeepSeek UI", "WindUI 1.6.65 · square corners · random whale art")
end, 24, nil, Color3.fromHex("#4D6BFE"))

pcall(function()
	Window:Tag({ Title = "v1.6.65", Icon = "lucide:badge-check" })
end)

local Home = Window:Tab({ Title = "Home", Icon = "lucide:house" })
local Controls = Window:Tab({ Title = "Controls", Icon = "lucide:sliders-horizontal" })
local Scripts = Window:Tab({ Title = "Scripts", Icon = "lucide:code" })
local Look = Window:Tab({ Title = "Look", Icon = "lucide:palette" })
local Info = Window:Tab({ Title = "About", Icon = "lucide:whale" })

Call(Home, "Section", { Title = "Overview" })
Call(Home, "Paragraph", {
	Title = "DeepSeek UI",
	Desc = "Square corners, DeepSeek blue, random whale wallpaper, a pet hiding behind the left edge, a sitter on the top rail and a sticker in the corner. Drag the window and watch the frame glow.",
})
Call(Home, "Button", {
	Title = "Send Notification",
	Desc = "Top right toast",
	Callback = function()
		notify("DeepSeek", "Hello from the whale.")
	end,
})
Call(Home, "Button", {
	Title = "Open Dialog",
	Desc = "Modal with two buttons",
	Callback = function()
		Window:Dialog({
			Title = "Confirm",
			Content = "Run the selected script now?",
			Buttons = {
				{ Title = "Cancel", Callback = function() end, Variant = "Secondary" },
				{ Title = "Run", Callback = function() notify("Running", "Script started.") end, Variant = "Primary" },
			},
		})
	end,
})
Call(Home, "Divider")
Call(Home, "Toggle", {
	Title = "Auto Run",
	Desc = "Execute on injection",
	Value = true,
	Callback = function(state) print("[AutoRun]", state) end,
})
Call(Home, "Slider", {
	Title = "Walk Speed",
	Desc = "Character movement speed",
	Value = { Min = 16, Max = 300, Default = 32 },
	Callback = function(v) print("[Speed]", v) end,
})
Call(Home, "Dropdown", {
	Title = "Target Mode",
	Desc = "Who the script targets",
	Values = { "Nearest", "Lowest Health", "Highest Health", "Random" },
	Value = "Nearest",
	Callback = function(v) print("[Target]", v) end,
})
Call(Home, "Input", {
	Title = "Player Name",
	Desc = "Whitelist a player",
	Placeholder = "type a name...",
	Value = "",
	Callback = function(v) print("[Name]", v) end,
})
Call(Home, "Keybind", {
	Title = "Toggle Menu",
	Desc = "Open or close the window",
	Value = "K",
	Callback = function(k) print("[Keybind]", k) end,
})
Call(Home, "Colorpicker", {
	Title = "Accent Color",
	Desc = "Highlight tone",
	Default = Color3.fromHex("#4D6BFE"),
	Callback = function(c) print("[Accent]", c) end,
})

Call(Controls, "Section", { Title = "Multi Choice" })
Call(Controls, "Dropdown", {
	Title = "Features",
	Desc = "Multiple selection",
	Values = { "ESP", "Aimbot", "Fly", "Speed", "Noclip", "Teleport" },
	Value = { "ESP", "Speed" },
	Multi = true,
	Callback = function(list)
		print("[Features]", table.concat(list, ", "))
	end,
})
Call(Controls, "Section", { Title = "Numbers" })
Call(Controls, "Slider", {
	Title = "Field of View",
	Desc = "Camera FOV",
	Value = { Min = 40, Max = 120, Default = 70 },
	Callback = function(v) print("[FOV]", v) end,
})
Call(Controls, "Slider", {
	Title = "Volume",
	Desc = "Sound level",
	Value = { Min = 0, Max = 100, Default = 50 },
	Callback = function(v) print("[Volume]", v) end,
})
Call(Controls, "Divider")
Call(Controls, "Section", { Title = "Switches" })
Call(Controls, "Toggle", {
	Title = "ESP Boxes",
	Desc = "Draw boxes around players",
	Value = false,
	Callback = function(v) print("[ESP]", v) end,
})
Call(Controls, "Toggle", {
	Title = "Team Check",
	Desc = "Ignore teammates",
	Value = true,
	Callback = function(v) print("[TeamCheck]", v) end,
})
Call(Controls, "Toggle", {
	Title = "Silent Aim",
	Desc = "Redirect bullets",
	Value = false,
	Callback = function(v) print("[SilentAim]", v) end,
})
Call(Controls, "Input", {
	Title = "Custom Prefix",
	Desc = "Command prefix",
	Placeholder = ";",
	Value = ";",
	Callback = function(v) print("[Prefix]", v) end,
})
Call(Controls, "Keybind", {
	Title = "Panic Key",
	Desc = "Reset everything",
	Value = "RightShift",
	Callback = function(k) print("[Panic]", k) end,
})

Call(Scripts, "Section", { Title = "Loaders" })
for _, item in ipairs({
	{ title = "Infinite Yield", desc = "Admin panel", tag = "admin" },
	{ title = "ESP Suite", desc = "Highlight all players", tag = "visual" },
	{ title = "Auto Farm", desc = "Loop the grind", tag = "farm" },
	{ title = "Teleport Hub", desc = "Waypoint travel", tag = "move" },
}) do
	Call(Scripts, "Button", {
		Title = item.title,
		Desc = item.desc,
		Callback = function()
			notify(item.title, "Loaded (" .. item.tag .. ")")
		end,
	})
end
Call(Scripts, "Divider")
Call(Scripts, "Paragraph", {
	Title = "Notice",
	Desc = "Buttons here only fire a toast. Wire your executor calls into the Callback field.",
})
Call(Scripts, "Button", {
	Title = "Clear All",
	Desc = "Reset every toggle",
	Callback = function()
		notify("Cleared", "All toggles reset.")
	end,
})

Call(Look, "Section", { Title = "Theme" })
Call(Look, "Button", {
	Title = "Dark",
	Desc = "#070B13 with DeepSeek blue",
	Callback = function() WindUI:SetTheme("Dark") end,
})
Call(Look, "Button", {
	Title = "Light",
	Desc = "#FFFFFF with DeepSeek blue",
	Callback = function() WindUI:SetTheme("Light") end,
})
Call(Look, "Button", {
	Title = "Random",
	Desc = "Pick a random palette",
	Callback = function() WindUI:SetTheme(math.random(2) == 1 and "Dark" or "Light") end,
})
Call(Look, "Slider", {
	Title = "UI Scale",
	Desc = "Resize the whole interface",
	Value = { Min = 70, Max = 130, Default = 100 },
	Callback = function(v) Window:SetUIScale(v / 100) end,
})
Call(Look, "Toggle", {
	Title = "Fullscreen",
	Desc = "Stretch to the viewport",
	Value = false,
	Callback = function(v) Window:ToggleFullscreen(v) end,
})
Call(Look, "Divider")
Call(Look, "Section", { Title = "Window" })
Call(Look, "Button", { Title = "Center", Desc = "Snap to screen center", Callback = function() Window:SetToTheCenter() end })
Call(Look, "Button", { Title = "Lock All", Desc = "Freeze every element", Callback = function() Window:LockAll() end })
Call(Look, "Button", { Title = "Unlock All", Desc = "Release every element", Callback = function() Window:UnlockAll() end })
Call(Look, "Input", { Title = "Window Title", Desc = "Rename the header", Placeholder = "DeepSeek", Value = "DeepSeek", Callback = function(v) Window:SetTitle(v) end })
Call(Look, "Keybind", { Title = "Toggle Window", Desc = "Show or hide", Value = "RightControl", Callback = function(k) print("[Toggle]", k) end })

Call(Info, "Section", { Title = "DeepSeek UI" })
Call(Info, "Paragraph", {
	Title = "WindUI 1.6.65 fork",
	Desc = "Square corners, search bar above the tabs, DeepSeek blue palette, random whale wallpapers, edge pet behind the window, sitter on the top rail, corner sticker with drag shuffle.",
})
Call(Info, "Paragraph", {
	Title = "Assets",
	Desc = "34 files on GitHub: 2 wallpapers, 5 cutouts, 10 banners and 17 expression stickers.",
})
Call(Info, "Divider")
Call(Info, "Button", {
	Title = "Copy Repo Link",
	Desc = "github.com/lIllIIlII/NEW",
	Callback = function()
		if setclipboard then setclipboard("https://github.com/lIllIIlII/NEW") end
		notify("Copied", "https://github.com/lIllIIlII/NEW")
	end,
})
Call(Info, "Button", {
	Title = "Reload Assets",
	Desc = "Drop the local cache",
	Callback = function()
		if delfile and isfile and isfile("DeepSeekUI") then delfile("DeepSeekUI") end
		notify("Cache", "Cleared, rejoin to redownload.")
	end,
})
Call(Info, "Toggle", {
	Title = "Debug Mode",
	Desc = "Print element errors",
	Value = false,
	Callback = function(v)
		if Window.Window then Window.Window.Debug = v end
		WindUI.Debug = v
	end,
})

Window:OnOpen(function() print("[DeepSeekUI] opened") end)
Window:OnClose(function() print("[DeepSeekUI] closed") end)

Window:SelectTab(Home)

task.delay(0.6, function()
	notify("DeepSeek UI", "Loaded. Search sits above the tabs now.")
end)
