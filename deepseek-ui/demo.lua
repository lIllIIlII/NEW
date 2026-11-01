-- main.lua lives in the executor workspace (Delta/Workspace).
-- Absolute paths are not readable there: the executor resolves names
-- relative to its workspace folder, so we try several spellings.
local DS_DEMO_VERSION = "70"
print("[DeepSeekUI] demo build " .. DS_DEMO_VERSION)

local CANDIDATES = {
	"main.lua",
	"Workspace/main.lua",
	"Delta/Workspace/main.lua",
}

local function tryRead(name)
	local ok, data = pcall(function()
		if readfile then
			return readfile(name)
		end
		return nil
	end)
	if ok and type(data) == "string" and #data > 1000 then
		return data
	end
	ok, data = pcall(function()
		if io and io.open then
			local f = io.open(name, "r")
			if f then
				local t = f:read("*a")
				f:close()
				return t
			end
		end
		return nil
	end)
	if ok and type(data) == "string" and #data > 1000 then
		return data
	end
	return nil
end

local src
for _, name in ipairs(CANDIDATES) do
	src = tryRead(name)
	if src then
		print("[DeepSeekUI] main.lua <- " .. name .. " (" .. #src .. " bytes)")
		break
	end
end

if not src then
	error("[DeepSeekUI] main.lua not found in workspace: " .. table.concat(CANDIDATES, ", "))
end

local WindUI = loadstring(src)()

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
	if res and props and props.Title and _G.DS_RegisterJump then
		_G.DS_RegisterJump(props.Title, res, Group)
	end
	return res
end

local Group = "Home"

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

-- Tag: icon only, no text.
_G.DS_WindUI = WindUI
_G.DS_Window = Window

-- Tag keeps the stock WindUI control; only an icon is used, resolved through
-- the same icon pack path as lucide (pack "ds" is registered by the library).
-- Resolve the lockup locally first: passing a getcustomasset path avoids
-- WindUI's async URL loader, which races with the tag frame and errors out.
pcall(function()
	Window:Tag({ Title = "", Icon = "lucide:sparkles" })
end)

-- CreateWindow returns the window object itself (not a wrapper), so the
-- element tree lives at Window.UIElements.Main. Every previous attempt used
-- Window.Window.UIElements... which is nil, which is why nothing was painted.
-- Two extra topbar buttons (the brand icons and the hidden fullscreen
-- button are handled globally inside main.lua).
Window:CreateTopbarButton("Info", "info", function()
	notify("DeepSeek UI", "WindUI 1.6.65 fork with a DeepSeek skin.")
end, 24, nil, Color3.fromHex("#4D6BFE"))

Window:CreateTopbarButton("Jump", "search", function()
	if _G.DS_OpenJump then
		_G.DS_OpenJump()
	end
end, 24, nil, Color3.fromHex("#4D6BFE"))

local Home = Window:Tab({ Title = "Home", Icon = "lucide:house" })
local Controls = Window:Tab({ Title = "Controls", Icon = "lucide:sliders-horizontal" })
local Scripts = Window:Tab({ Title = "Scripts", Icon = "lucide:code" })
local Look = Window:Tab({ Title = "Appearance", Icon = "lucide:palette" })
local About = Window:Tab({ Title = "About", Icon = "lucide:info" })

Group = "Home"
Call(Home, "Section", { Title = "Overview" })
Call(Home, "Paragraph", {
	Title = "DeepSeek UI",
	Desc = "A WindUI fork with a DeepSeek skin: square panels, deep blue accents, random whale wallpapers, an edge pet, a top-rail sitter, a corner sticker and a pixel marquee.",
})

-- Button: a clickable row. Callback fires on press.
Call(Home, "Button", {
	Title = "Send Notification",
	Desc = "Shows a toast in the top right corner",
	Callback = function()
		notify("DeepSeek", "Hello from the whale.")
	end,
})

-- Button that opens a modal with custom buttons.
Call(Home, "Button", {
	Title = "Open Dialog",
	Desc = "Modal window with two actions",
	Callback = function()
		Window:Dialog({
			Title = "Confirm",
			Content = "Run the selected script now?",
			Buttons = {
				{ Title = "Cancel", Callback = function() end, Variant = "Secondary" },
				{ Title = "Run", Callback = function() notify("Started", "Script is running.") end, Variant = "Primary" },
			},
		})
	end,
})

Call(Home, "Divider")

-- Toggle: a switch. Callback receives the new boolean state.
Call(Home, "Toggle", {
	Title = "Auto Run",
	Desc = "Execute right after injection",
	Value = true,
	Callback = function(state)
		tick("Auto Run", state)
	end,
})

-- Slider: returns a number. Value table defines Min / Max / Default.
Call(Home, "Slider", {
	Title = "Walk Speed",
	Desc = "Character movement speed",
	Value = { Min = 16, Max = 300, Default = 32 },
	Callback = function(v) print("[Speed]", v) end,
})

-- Dropdown (single): select one value from the list.
Call(Home, "Dropdown", {
	Title = "Target Mode",
	Desc = "Which player the script locks onto",
	Values = { "Nearest", "Lowest Health", "Highest Health", "Random" },
	Value = "Nearest",
	Callback = function(v) print("[Target]", v) end,
})

-- Input: free text field. Callback fires on submit.
Call(Home, "Input", {
	Title = "Player Name",
	Desc = "Add a player to the whitelist",
	Placeholder = "type a name...",
	Value = "",
	Callback = function(v) print("[Name]", v) end,
})

-- Keybind: captures a key press and returns the key name.
Call(Home, "Keybind", {
	Title = "Toggle Menu",
	Desc = "Open or close the window",
	Value = "K",
	Callback = function(k) print("[Keybind]", k) end,
})

-- Colorpicker: returns a Color3.
Call(Home, "Colorpicker", {
	Title = "Accent Color",
	Desc = "Highlight tone used across the UI",
	Default = Color3.fromHex("#4D6BFE"),
	Callback = function(c) print("[Accent]", c) end,
})

Group = "Controls"
Call(Controls, "Section", { Title = "Multi Choice" })

-- Dropdown with Multi = true: returns an array of selected values.
Call(Controls, "Dropdown", {
	Title = "Features",
	Desc = "Multiple selection at once",
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
	Callback = function(v) tick("ESP Boxes", v) end,
})
Call(Controls, "Toggle", {
	Title = "Team Check",
	Desc = "Ignore teammates",
	Value = true,
	Callback = function(v) tick("Team Check", v) end,
})
Call(Controls, "Toggle", {
	Title = "Silent Aim",
	Desc = "Redirect bullets",
	Value = false,
	Callback = function(v) tick("Silent Aim", v) end,
})
Call(Controls, "Input", {
	Title = "Custom Prefix",
	Desc = "Command prefix used in chat",
	Placeholder = ";",
	Value = ";",
	Callback = function(v) print("[Prefix]", v) end,
})
Call(Controls, "Keybind", {
	Title = "Panic Key",
	Desc = "Reset every feature at once",
	Value = "RightShift",
	Callback = function(k) print("[Panic]", k) end,
})

Group = "Scripts"
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

Group = "Appearance"

-- Font picker: DS_SetFontIndex ships with Source Sans / Gotham / Noto Sans /
-- Roboto / Montserrat, plus any "font.ttf" dropped in the workspace and any
-- font loaded through _G.DS_LoadFontUrl("https://.../font.ttf").
Call(Look, "Dropdown", {
	Title = "Font",
	Description = "UI typeface (CJK-capable options included)",
	Values = (function()
		local ok, list = pcall(function()
			return _G.DS_FontNames and _G.DS_FontNames()
		end)
		if ok and type(list) == "table" and #list > 0 then
			return list
		end
		return { "Source Sans", "Gotham", "Noto Sans", "Roboto", "Montserrat" }
	end)(),
	Callback = function(opt)
		local ok, names = pcall(function()
			return (_G.DS_FontNames and _G.DS_FontNames()) or {}
		end)
		if not ok or type(names) ~= "table" then
			names = { "Source Sans", "Gotham", "Noto Sans", "Roboto", "Montserrat" }
		end
		for i, n in ipairs(names) do
			if n == opt then
				_G.DS_SetFontIndex(i)
				return
			end
		end
	end,
})

-- Accent picker: recolours every themed element at runtime.
Call(Look, "Colorpicker", {
	Title = "Accent Color",
	Description = "Highlight tone used across the UI",
	Default = Color3.fromHex("#4D6BFE"),
	Callback = function(c)
		if _G.DS_SetPalette then
			_G.DS_SetPalette(c)
		end
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
Call(Look, "Section", { Title = "Text Size" })
Call(Look, "Slider", {
	Title = "Font Scale",
	Desc = "Scales every label, keeps the default font",
	Value = { Min = 70, Max = 150, Default = 107 },
	Callback = function(v)
		if _G.DS_SetFontScale then _G.DS_SetFontScale(v / 100) end
	end,
})

Call(Look, "Divider")
Call(Look, "Section", { Title = "Modules" })
for _, m in ipairs({
	{ k = "pet", t = "Edge Pet", d = "Whale girl peeking from the left edge" },
	{ k = "sitter", t = "Top Sitter", d = "Character sitting on the top rail" },
	{ k = "sticker", t = "Corner Sticker", d = "Clickable sticker in the bottom-right" },
	{ k = "ticker", t = "Marquee", d = "Scrolling feature list on the right" },
	{ k = "bg", t = "Wallpaper", d = "Random whale wallpaper behind the panels" },
	{ k = "sheen", t = "Sheen", d = "Light band that sweeps across the window" },
	{ k = "jag", t = "Jagged Edge", d = "Irregular outline around the window" },
	{ k = "glow", t = "Drag Glow", d = "Outline lights up while dragging" },
	{ k = "sound", t = "Load Sound", d = "Audio played when the UI appears" },
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
Call(Look, "Section", { Title = "Feature Index" })
Call(Look, "Button", {
	Title = "Open Index",
	Desc = "Popup listing every registered control",
	Callback = function()
		if _G.DS_OpenJump then _G.DS_OpenJump() end
	end,
})
Call(Look, "Button", {
	Title = "Register Custom Entry",
	Desc = "Demo of _G.DS_RegisterJump(name, object, group)",
	Callback = function()
		local obj = Call(Look, "Paragraph", {
			Title = "Temp Entry " .. tostring(math.random(100, 999)),
			Desc = "Generated at runtime and registered into the index.",
		})
		if obj and _G.DS_RegisterJump then
			_G.DS_RegisterJump("Temp Entry", obj, "Appearance")
		end
		notify("Registered", "Open the index to see it.")
	end,
})

Group = "About"
Call(About, "Section", { Title = "DeepSeek UI" })
Call(About, "Paragraph", {
	Title = "WindUI 1.6.65 fork",
	Desc = "Square panels, search bar above the tab list, DeepSeek blue palette, random whale wallpapers, edge pet, top sitter, corner sticker, pixel marquee and a global feature index.",
})
Call(About, "Paragraph", {
	Title = "Assets",
	Desc = "15 wallpapers, 12 character arts, 10 banners, 8 stickers, 4 official DeepSeek logos and a 125-entry icon pack, all served from GitHub.",
})
Call(About, "Button", {
	Title = "Replay Load Sound",
	Desc = "Play the startup audio again",
	Callback = function()
		if _G.DS_PlaySound then _G.DS_PlaySound(0.6) end
	end,
})
Call(About, "Button", {
	Title = "Stop Sound",
	Desc = "Silence the current audio",
	Callback = function()
		if _G.DS_StopSound then _G.DS_StopSound() end
	end,
})
Call(About, "Button", {
	Title = "Copy Repo Link",
	Desc = "github.com/lIllIIlII/NEW",
	Callback = function()
		if setclipboard then setclipboard("https://github.com/lIllIIlII/NEW") end
		notify("Copied", "https://github.com/lIllIIlII/NEW")
	end,
})
Call(About, "Toggle", {
	Title = "Debug Mode",
	Desc = "Print element errors to the console",
	Value = false,
	Callback = function(v)
		if Window.Debug ~= nil then Window.Debug = v end
		WindUI.Debug = v
	end,
})

Window:OnOpen(function() print("[DeepSeekUI] opened") end)
Window:OnClose(function() print("[DeepSeekUI] closed") end)

Window:SelectTab(Home)

task.delay(0.6, function()
	if _G.DS_Ticker then
		_G.DS_Ticker.Set({ "Auto Run", "Team Check", "ESP Boxes", "Sound", "Marquee" })
	end
	notify("DeepSeek UI", "Loaded. Search sits above the tabs.")
end)
