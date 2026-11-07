local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local unpack = table.unpack or unpack

UI = UI or { DS = nil }

local function Cam()
    return Workspace.CurrentCamera
end

local function Char()
    local c = LP.Character
    if c and c.Parent then
        return c
    end
end

local function Root()
    local c = Char()
    return c and c.PrimaryPart
end

local function Hum()
    local c = Char()
    return c and c:FindFirstChildWhichIsA("Humanoid")
end

local function PartOf(m)
    if not m then
        return nil
    end
    if m:IsA("BasePart") then
        return m
    end
    local p = m.PrimaryPart
    if p and p.Parent then
        return p
    end
    for _, d in ipairs(m:GetDescendants()) do
        if d:IsA("BasePart") then
            return d
        end
    end
end

local function SetVel(part, v)
    pcall(function()
        part.AssemblyLinearVelocity = v
    end)
end

local Net = nil
local RC = {}
local Miss = {}

local function FindNet()
    local ok, r = pcall(function()
        return ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged
    end)
    if ok and r then
        return r
    end
    local ok2, r2 = pcall(function()
        return ReplicatedStorage:FindFirstChild("_NetManaged", true)
    end)
    if ok2 and r2 then
        return r2
    end
end

Net = FindNet()

local function NM()
    if Net and Net.Parent then
        return Net
    end
    Net = FindNet()
    return Net
end

local function FindR(name)
    local nm = NM()
    if nm then
        local ok, r = pcall(function()
            return nm:FindFirstChild(name, true)
        end)
        if ok and r then
            return r
        end
    end
    if string.find(name, "/", 1, true) then
        local ns, leaf = string.match(name, "^(.-)/(.+)$")
        if ns and leaf then
            local ok2, r2 = pcall(function()
                local f = ReplicatedStorage:FindFirstChild(ns, true)
                return f and f:FindFirstChild(leaf, true)
            end)
            if ok2 and r2 then
                return r2
            end
        end
    end
    local ok3, r3 = pcall(function()
        return ReplicatedStorage:FindFirstChild(name, true)
    end)
    if ok3 and r3 then
        return r3
    end
end

local function R(name)
    local c = RC[name]
    if c and c.Parent then
        return c
    end
    if Miss[name] then
        return nil
    end
    local f = FindR(name)
    RC[name] = f
    if not f then
        Miss[name] = true
    end
    return f
end

local function Call(name, ...)
    local r = R(name)
    if not r then
        return false, nil
    end
    local a = { ... }
    local ok, res = pcall(function()
        if r:IsA("RemoteFunction") then
            return r:InvokeServer(unpack(a))
        end
        r:FireServer(unpack(a))
        return true
    end)
    if not ok then
        return false, nil
    end
    return true, res
end

local CFG = {
    EspPlayer = true,
    EspNpc = true,
    EspDummy = true,
    EspDist = 500,
    EspHp = true,
    EspItem = true,

    BedEsp = false,
    BedPlate = false,
    StorageEsp = false,
    HealthHud = false,
    KitEsp = false,

    Aimbot = false,
    AimbotFov = 200,
    AimbotSmooth = 0.35,
    Silent = false,
    ProjAim = false,

    Aura = false,
    AuraRange = 13,
    AuraMax = 4,
    AuraAngle = 360,
    AuraFace = true,

    Pickup = false,
    PickupRange = 60,
    Gen = false,
    Armor = false,
    Shop = false,
    Tool = false,
    Claim = false,
    ClaimGap = 60,
    Consume = false,
    ConsumeHp = 70,
    ChestSteal = false,
    VoidDrop = false,
    AntiAfk = false,

    Speed = false,
    SpeedVal = 32,
    AntiFall = false,
    AntiFallY = -18,
    Team = true,

    Ticker = true,
    TickerTarget = true,
    Theme = "Dark",
}

local function Alive(m)
    if not m or not m.Parent then
        return false
    end
    if m:GetAttribute("Dead") == true then
        return false
    end
    local h = m:GetAttribute("Health")
    if h ~= nil then
        return h > 0
    end
    local hum = m:FindFirstChildWhichIsA("Humanoid")
    if hum then
        return hum.Health > 0
    end
    return true
end

local function MyTeam()
    local c = Char()
    if not c then
        return nil
    end
    local t = c:GetAttribute("Team")
    if t == nil then
        t = c:GetAttribute("TeamId")
    end
    return t
end

local function SameTeam(m)
    if not CFG.Team then
        return false
    end
    local mine = MyTeam()
    if mine == nil then
        return false
    end
    local t = m:GetAttribute("Team")
    if t == nil then
        t = m:GetAttribute("TeamId")
    end
    if t == nil then
        return false
    end
    return t == mine
end

local function Dummy(m)
    if m:GetAttribute("DummyPlayerEntity") == true then
        return true
    end
    local ok, h = pcall(function()
        return CollectionService:HasTag(m, "trainingRoomDummy")
    end)
    return ok and h
end

local World = { list = {}, at = 0 }

local function Scan()
    local out, seen = {}, {}
    local r = Root()
    local org = r and r.Position or Cam().CFrame.Position
    local me = Char()
    pcall(function()
        for _, m in ipairs(CollectionService:GetTagged("entity")) do
            if m ~= me and not seen[m] and m.Parent and Alive(m) then
                seen[m] = true
                local p = PartOf(m)
                if p then
                    local plr = Players:GetPlayerFromCharacter(m)
                    local isP = plr ~= nil or m:GetAttribute("PlayerUserId") ~= nil
                    local k = "npc"
                    if isP then
                        k = "player"
                    elseif Dummy(m) then
                        k = "dummy"
                    end
                    local n = m.Name
                    if plr then
                        n = plr.Name
                    else
                        local mt = m:GetAttribute("MonsterType")
                        local bt = m:GetAttribute("BossType")
                        if bt then
                            n = tostring(bt)
                        elseif mt then
                            n = tostring(mt)
                        end
                    end
                    if not SameTeam(m) then
                        out[#out + 1] = { model = m, part = p, kind = k, name = n, dist = (p.Position - org).Magnitude }
                    end
                end
            end
        end
    end)
    pcall(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local c = plr.Character
                if c and c.Parent and Alive(c) and not seen[c] and not SameTeam(c) then
                    seen[c] = true
                    local p = PartOf(c)
                    if p then
                        out[#out + 1] = { model = c, part = p, kind = "player", name = plr.Name, dist = (p.Position - org).Magnitude }
                    end
                end
            end
        end
    end)
    table.sort(out, function(a, b)
        return a.dist < b.dist
    end)
    World.list = out
    World.at = os.clock()
    return out
end

local function Targets()
    if os.clock() - World.at > 0.12 then
        return Scan()
    end
    local l = World.list
    local r = Root()
    if r then
        local p = r.Position
        for _, t in ipairs(l) do
            if t.part and t.part.Parent then
                t.dist = (t.part.Position - p).Magnitude
            else
                t.dist = math.huge
            end
        end
    end
    return l
end

local function Inv()
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    local priv = pg and pg:FindFirstChild("PrivateInventory")
    if priv then
        return priv:FindFirstChild(LP.Name) or priv
    end
    local c = Char()
    local l = c and c:FindFirstChild("InventoryFolder")
    if l and l:IsA("ObjectValue") and l.Value then
        return l.Value
    end
    local invs = ReplicatedStorage:FindFirstChild("Inventories")
    if invs then
        return invs:FindFirstChild(LP.Name)
    end
end

local function Hand()
    local c = Char()
    if not c then
        return nil
    end
    local l = c:FindFirstChild("HandInvItem")
    if l and l:IsA("ObjectValue") and l.Value then
        return l.Value
    end
    local inv = Inv()
    if inv then
        for _, o in ipairs(inv:GetChildren()) do
            if o:IsA("Tool") or o:IsA("Accessory") then
                return o
            end
        end
    end
end

local function Equip(tool)
    if not tool or not tool.Parent then
        return false
    end
    local c = Char()
    if not c then
        return false
    end
    local l = c:FindFirstChild("HandInvItem")
    if l and l:IsA("ObjectValue") and l.Value == tool then
        return true
    end
    local ok = Call("SetInvItem", { hand = tool })
    if l and l:IsA("ObjectValue") then
        pcall(function()
            l.Value = tool
        end)
    end
    return ok
end

local SW = { "sword", "blade", "saber", "rapier", "dagger", "axe", "scythe", "hammer" }

local function IsSword(n)
    local s = string.lower(tostring(n))
    for _, k in ipairs(SW) do
        if string.find(s, k, 1, true) then
            return true
        end
    end
    return false
end

local function Sword()
    local h = Hand()
    if h and IsSword(h.Name) then
        return h
    end
    local inv = Inv()
    if inv then
        for _, o in ipairs(inv:GetChildren()) do
            if (o:IsA("Tool") or o:IsA("Accessory")) and IsSword(o.Name) then
                if Equip(o) then
                    task.wait(0.04)
                end
                return o
            end
        end
    end
    return h
end

local Dirs = {}

local function Dir(name)
    local d = Dirs[name]
    if d and d.Parent then
        return d
    end
    local f
    pcall(function()
        f = Instance.new("Folder")
        f.Name = name
        f.Parent = CoreGui
    end)
    if not f then
        pcall(function()
            f = Instance.new("Folder")
            f.Name = name
            f.Parent = LP:FindFirstChildOfClass("PlayerGui") or LP
        end)
    end
    Dirs[name] = f
    return f
end

local function Bbg(parent, adornee, size, offset, maxDist)
    local bb = Instance.new("BillboardGui")
    bb.Adornee = adornee
    bb.Size = size
    bb.StudsOffsetWorldSpace = offset
    bb.AlwaysOnTop = true
    bb.MaxDistance = maxDist or 2000
    bb.LightInfluence = 0
    bb.ResetOnSpawn = false
    bb.Parent = parent
    return bb
end

local function Txt(parent, size, color, textSize, strokeAlpha)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Size = size
    t.Font = Enum.Font.Arcade
    t.TextSize = textSize
    t.TextColor3 = color
    t.TextStrokeTransparency = strokeAlpha or 0
    t.TextStrokeColor3 = Color3.new(0, 0, 0)
    t.TextXAlignment = Enum.TextXAlignment.Center
    t.Parent = parent
    return t
end

local function Bar(parent, y, width, height)
    local bg = Instance.new("Frame")
    bg.AnchorPoint = Vector2.new(0.5, 0)
    bg.Position = UDim2.new(0.5, 0, 0, y)
    bg.Size = UDim2.fromOffset(width, height)
    bg.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    bg.BorderSizePixel = 0
    bg.Parent = parent
    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(1, 1)
    fill.BackgroundColor3 = Color3.fromRGB(96, 240, 128)
    fill.BorderSizePixel = 0
    fill.Parent = bg
    local st = Instance.new("UIStroke")
    st.Thickness = 1
    st.Color = Color3.new(0, 0, 0)
    st.Transparency = 0.25
    st.Parent = bg
    return bg, fill
end

local function Wipe(cache)
    for k, e in pairs(cache) do
        if e then
            for _, o in pairs(e) do
                if typeof(o) == "Instance" then
                    pcall(function()
                        o:Destroy()
                    end)
                end
            end
        end
        cache[k] = nil
    end
end

local Esp = { cache = {} }

local EC = {
    player = Color3.fromRGB(255, 96, 96),
    npc = Color3.fromRGB(255, 178, 64),
    dummy = Color3.fromRGB(96, 200, 255),
}

local function HP(m)
    local h = m:GetAttribute("Health")
    local mx = m:GetAttribute("MaxHealth") or m:GetAttribute("BaseMaxHealth")
    if h == nil then
        local hum = m:FindFirstChildWhichIsA("Humanoid")
        if hum then
            h = hum.Health
            mx = hum.MaxHealth
        end
    end
    if h == nil then
        return nil, nil
    end
    if not mx or mx <= 0 then
        mx = 100
    end
    return h, mx
end

local function KindTag(t)
    if t.model:GetAttribute("BossType") then
        return "BOSS"
    end
    if t.kind == "player" then
        return "PVP"
    end
    if t.kind == "dummy" then
        return "DUMMY"
    end
    return "NPC"
end

local function MkEsp(t)
    local dir = Dir("DS_ESP")
    if not dir then
        return nil
    end
    local col = EC[t.kind] or EC.npc
    local e = {}
    local hl = Instance.new("Highlight")
    hl.FillColor = col
    hl.FillTransparency = 0.78
    hl.OutlineColor = col
    hl.OutlineTransparency = 0.15
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = t.model
    hl.Parent = dir
    e.hl = hl
    local bb = Bbg(dir, t.part, UDim2.fromOffset(150, 34), Vector3.new(0, 2.9, 0), 3000)
    e.bb = bb
    local n = Txt(bb, UDim2.new(1, 0, 0, 15), col, 13)
    e.name = n
    local bg, fill = Bar(bb, 16, 100, 4)
    e.bg = bg
    e.bar = fill
    local inf = Txt(bb, UDim2.new(1, 0, 0, 12), Color3.fromRGB(214, 214, 214), 10, 0.35)
    inf.Position = UDim2.fromOffset(0, 21)
    e.info = inf
    return e
end

local function EspTick()
    local dir = Dir("DS_ESP")
    if not dir then
        return
    end
    local live = {}
    for _, t in ipairs(Targets()) do
        if t.dist <= CFG.EspDist and t.part and t.part.Parent then
            local w
            if t.kind == "player" then
                w = CFG.EspPlayer
            elseif t.kind == "dummy" then
                w = CFG.EspDummy
            else
                w = CFG.EspNpc
            end
            if w then
                live[t.model] = t
            end
        end
    end
    for m, t in pairs(live) do
        local e = Esp.cache[m]
        if not e or not e.bb or not e.bb.Parent then
            e = MkEsp(t)
            Esp.cache[m] = e
        end
        if e then
            local col = EC[t.kind] or EC.npc
            if e.hl then
                e.hl.FillColor = col
                e.hl.OutlineColor = col
                e.hl.Adornee = t.model
            end
            if e.bb then
                e.bb.Adornee = t.part
            end
            if e.name then
                e.name.Text = t.name
                e.name.TextColor3 = col
            end
            local h, mx = HP(t.model)
            if e.bg and e.bar then
                if CFG.EspHp and h then
                    local r = math.clamp(h / mx, 0, 1)
                    e.bg.Visible = true
                    e.bar.Size = UDim2.fromScale(r, 1)
                    e.bar.BackgroundColor3 = r > 0.5 and Color3.fromRGB(96, 240, 128)
                        or (r > 0.25 and Color3.fromRGB(255, 208, 72) or Color3.fromRGB(255, 84, 84))
                else
                    e.bg.Visible = false
                end
            end
            if e.info then
                local b = { KindTag(t) }
                if CFG.EspHp and h then
                    b[#b + 1] = string.format("%d", math.floor(h))
                end
                if CFG.EspItem then
                    local l = t.model:FindFirstChild("HandInvItem")
                    if l and l:IsA("ObjectValue") and l.Value then
                        b[#b + 1] = l.Value.Name
                    end
                end
                b[#b + 1] = string.format("%dm", math.floor(t.dist))
                e.info.Text = table.concat(b, " · ")
            end
        end
    end
    for m in pairs(Esp.cache) do
        if not live[m] then
            local e = Esp.cache[m]
            if e then
                for _, o in pairs(e) do
                    if typeof(o) == "Instance" then
                        pcall(function()
                            o:Destroy()
                        end)
                    end
                end
            end
            Esp.cache[m] = nil
        end
    end
end

local Bed = { cache = {}, plate = {} }

local function TeamColor(id)
    local palette = {
        Color3.fromRGB(255, 96, 96), Color3.fromRGB(96, 160, 255),
        Color3.fromRGB(120, 235, 120), Color3.fromRGB(255, 210, 80),
        Color3.fromRGB(200, 130, 255), Color3.fromRGB(255, 150, 220),
        Color3.fromRGB(120, 235, 235), Color3.fromRGB(230, 230, 230),
    }
    local n = tonumber(id) or 0
    return palette[(n % #palette) + 1] or palette[1]
end

local function BedInfo(bed)
    local id = bed:GetAttribute("id")
    local team
    if type(id) == "string" then
        team = string.match(id, "^(%d+)_")
    end
    if not team then
        team = bed:GetAttribute("Team")
    end
    local alive = true
    if team ~= nil then
        if bed:GetAttribute("Team" .. tostring(team) .. "NoBreak") == nil then
            alive = false
        end
    end
    return team, alive
end

local function BedTick()
    local dir = Dir("DS_BED")
    if not dir then
        return
    end
    local live = {}
    pcall(function()
        for _, bed in ipairs(CollectionService:GetTagged("bed")) do
            local part = PartOf(bed)
            if part and part.Parent then
                live[bed] = part
            end
        end
    end)
    for bed, part in pairs(live) do
        local team, alive = BedInfo(bed)
        if CFG.BedEsp then
            local e = Bed.cache[bed]
            if not e or not e.hl or not e.hl.Parent then
                e = {}
                local hl = Instance.new("Highlight")
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillTransparency = 0.72
                hl.OutlineTransparency = 0.1
                hl.Adornee = bed
                hl.Parent = dir
                e.hl = hl
                Bed.cache[bed] = e
            end
            local col = alive and TeamColor(team) or Color3.fromRGB(110, 110, 110)
            e.hl.FillColor = col
            e.hl.OutlineColor = col
            e.hl.Adornee = bed
        elseif Bed.cache[bed] then
            local e = Bed.cache[bed]
            for _, o in pairs(e) do
                pcall(function()
                    o:Destroy()
                end)
            end
            Bed.cache[bed] = nil
        end
        if CFG.BedPlate then
            local e = Bed.plate[bed]
            if not e or not e.bb or not e.bb.Parent then
                e = {}
                local bb = Bbg(dir, part, UDim2.fromOffset(120, 26), Vector3.new(0, 2.4, 0), 2500)
                e.bb = bb
                e.txt = Txt(bb, UDim2.fromScale(1, 1), TeamColor(team), 13)
                Bed.plate[bed] = e
            end
            if e.txt then
                e.txt.Text = "TEAM " .. tostring(team or "?") .. (alive and " · ALIVE" or " · DEAD")
                e.txt.TextColor3 = alive and TeamColor(team) or Color3.fromRGB(150, 150, 150)
            end
            if e.bb then
                e.bb.Adornee = part
            end
        elseif Bed.plate[bed] then
            local e = Bed.plate[bed]
            for _, o in pairs(e) do
                pcall(function()
                    o:Destroy()
                end)
            end
            Bed.plate[bed] = nil
        end
    end
    for bed in pairs(Bed.cache) do
        if not live[bed] then
            local e = Bed.cache[bed]
            for _, o in pairs(e) do
                pcall(function()
                    o:Destroy()
                end)
            end
            Bed.cache[bed] = nil
        end
    end
    for bed in pairs(Bed.plate) do
        if not live[bed] then
            local e = Bed.plate[bed]
            for _, o in pairs(e) do
                pcall(function()
                    o:Destroy()
                end)
            end
            Bed.plate[bed] = nil
        end
    end
end

local Chest = { cache = {} }

local CHEST_TAGS = { "chest", "LuckyBlockDisplay", "VendingMachine", "CottonCandyMachine" }

local function ChestTick()
    local dir = Dir("DS_CHEST")
    if not dir then
        return
    end
    local live = {}
    pcall(function()
        for _, tag in ipairs(CHEST_TAGS) do
            for _, o in ipairs(CollectionService:GetTagged(tag)) do
                local p = PartOf(o)
                if p and p.Parent then
                    live[o] = { part = p, tag = tag }
                end
            end
        end
    end)
    for o, info in pairs(live) do
        if CFG.StorageEsp then
            local e = Chest.cache[o]
            if not e or not e.hl or not e.hl.Parent then
                e = {}
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(255, 215, 90)
                hl.FillTransparency = 0.7
                hl.OutlineColor = Color3.fromRGB(255, 215, 90)
                hl.OutlineTransparency = 0.1
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = o
                hl.Parent = dir
                e.hl = hl
                local bb = Bbg(dir, info.part, UDim2.fromOffset(110, 18), Vector3.new(0, 1.8, 0), 1200)
                e.bb = bb
                local t = Txt(bb, UDim2.fromScale(1, 1), Color3.fromRGB(255, 215, 90), 11, 0.2)
                t.Text = info.tag
                e.txt = t
                Chest.cache[o] = e
            end
            if e.bb then
                e.bb.Adornee = info.part
            end
        elseif Chest.cache[o] then
            local e = Chest.cache[o]
            for _, v in pairs(e) do
                pcall(function()
                    v:Destroy()
                end)
            end
            Chest.cache[o] = nil
        end
    end
    for o in pairs(Chest.cache) do
        if not live[o] then
            local e = Chest.cache[o]
            for _, v in pairs(e) do
                pcall(function()
                    v:Destroy()
                end)
            end
            Chest.cache[o] = nil
        end
    end
end

local Kit = { cache = {} }

local KIT_MAP = {
    alchemist = "wild_flower",
    beekeeper = "bee",
    bigman = "treeOrb",
    ghost_catcher = "ghost_orb",
    metal_detector = "iron",
    sheep_herder = "purple_hay_bale",
    sorcerer = "alchemy_crystal",
    star_collector = "crit_star",
}

local function KitTick()
    if not CFG.KitEsp then
        Wipe(Kit.cache)
        return
    end
    local dir = Dir("DS_KIT")
    if not dir then
        return
    end
    local kitName = LP:GetAttribute("PlayingAsKit")
    local icon = kitName and KIT_MAP[kitName]
    if not icon then
        return
    end
    local live = {}
    pcall(function()
        for _, o in ipairs(CollectionService:GetTagged(icon)) do
            local p = PartOf(o)
            if p and p.Parent then
                live[o] = p
            end
        end
    end)
    for o, p in pairs(live) do
        local e = Kit.cache[o]
        if not e or not e.bb or not e.bb.Parent then
            e = {}
            local bb = Bbg(dir, p, UDim2.fromOffset(40, 40), Vector3.new(0, 2.5, 0), 2000)
            e.bb = bb
            local f = Instance.new("Frame")
            f.Size = UDim2.fromScale(1, 1)
            f.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            f.BackgroundTransparency = 0.35
            f.BorderSizePixel = 0
            f.Parent = bb
            e.frame = f
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 6)
            c.Parent = f
            local t = Txt(f, UDim2.fromScale(1, 1), Color3.fromRGB(255, 230, 120), 9, 0.3)
            t.TextWrapped = true
            t.Text = icon
            e.txt = t
            Kit.cache[o] = e
        end
        if e.bb then
            e.bb.Adornee = p
        end
    end
    for o in pairs(Kit.cache) do
        if not live[o] then
            local e = Kit.cache[o]
            for _, v in pairs(e) do
                pcall(function()
                    v:Destroy()
                end)
            end
            Kit.cache[o] = nil
        end
    end
end

local HUD = { hp = nil }

local function HudTick()
    if not CFG.HealthHud then
        if HUD.hp then
            HUD.hp.Visible = false
        end
        return
    end
    if not HUD.hp then
        local sg = Instance.new("ScreenGui")
        sg.Name = "DS_HUD"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        pcall(function()
            sg.Parent = CoreGui
        end)
        if not sg.Parent then
            sg.Parent = LP:FindFirstChildOfClass("PlayerGui") or LP
        end
        HUD.gui = sg
        local t = Txt(sg, UDim2.fromOffset(140, 26), Color3.new(1, 1, 1), 18)
        t.AnchorPoint = Vector2.new(0.5, 0)
        t.Position = UDim2.new(0.5, 0, 0.62, 0)
        HUD.hp = t
    end
    local h, mx
    local c = Char()
    if c then
        h = c:GetAttribute("Health")
        mx = c:GetAttribute("MaxHealth") or 100
    end
    if h and HUD.hp then
        local r = math.clamp(h / mx, 0, 1)
        HUD.hp.Visible = true
        HUD.hp.Text = string.format("%d HP", math.floor(h))
        HUD.hp.TextColor3 = Color3.fromHSV(r / 2.8, 0.86, 1)
    elseif HUD.hp then
        HUD.hp.Visible = false
    end
end

local REACH = 14.399

local function Payload(t, w, cr)
    local c = Char()
    local r = c and c.PrimaryPart
    local m = t and t.model
    local p = m and (m.PrimaryPart or t.part)
    if not (r and p and p.Parent and w) then
        return nil
    end
    local sp = r.Position
    local tp = p.Position
    local d = tp - sp
    local dist = d.Magnitude
    if dist < 0.01 then
        return nil
    end
    local dir = d.Unit
    local push = sp + dir * math.max(dist - REACH, 0)
    return {
        weapon = w,
        entityInstance = m,
        chargedAttack = { chargeRatio = cr or 0 },
        validate = {
            raycast = {
                cameraPosition = { value = push },
                cursorDirection = { value = dir },
            },
            targetPosition = { value = tp },
            selfPosition = { value = push },
        },
    }
end

local SilentT = nil
local HitRemote = nil
local Hooked = false

local function HookSilent()
    if Hooked then
        return
    end
    local ok = pcall(function()
        local old
        old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local m = getnamecallmethod()
            if not checkcaller() and CFG.Silent and SilentT and HitRemote and self == HitRemote then
                if m == "FireServer" or m == "SendToServer" then
                    local a = { ... }
                    local d = a[1]
                    if type(d) == "table" and d.validate and SilentT.model and SilentT.model.Parent then
                        local p = SilentT.model.PrimaryPart or SilentT.part
                        if p then
                            local cam = Cam()
                            local cp = cam.CFrame.Position
                            local dir = p.Position - cp
                            if dir.Magnitude > 0.01 then
                                dir = dir.Unit
                                d.entityInstance = SilentT.model
                                d.validate.targetPosition = { value = p.Position }
                                d.validate.raycast = {
                                    cameraPosition = { value = cp },
                                    cursorDirection = { value = dir },
                                }
                            end
                        end
                    end
                end
            end
            return old(self, ...)
        end))
    end)
    Hooked = ok
end

local Aura = { on = false, sent = 0, last = "-", idx = 1 }

local function AuraLoop()
    if Aura.on then
        return
    end
    Aura.on = true
    task.spawn(function()
        while true do
            if not CFG.Aura then
                Aura.last = "-"
                Aura.idx = 1
                task.wait(0.1)
            else
                local c = Char()
                local r = c and c.PrimaryPart
                local w = r and Sword()
                if not (r and w) then
                    task.wait(0.25)
                else
                    local face = r.CFrame.LookVector * Vector3.new(1, 0, 1)
                    local list = {}
                    for _, t in ipairs(Targets()) do
                        if t.part and t.part.Parent and t.dist <= CFG.AuraRange then
                            local okA = true
                            if CFG.AuraAngle < 360 then
                                local flat = (t.part.Position - r.Position) * Vector3.new(1, 0, 1)
                                if flat.Magnitude > 0.01 then
                                    local dot = math.clamp(face:Dot(flat.Unit), -1, 1)
                                    okA = math.deg(math.acos(dot)) <= CFG.AuraAngle / 2
                                end
                            end
                            if okA then
                                list[#list + 1] = t
                            end
                        end
                    end
                    if #list == 0 then
                        task.wait(0.08)
                    else
                        if Aura.idx > #list then
                            Aura.idx = 1
                        end
                        local n = 0
                        for i = 0, math.min(CFG.AuraMax, #list) - 1 do
                            local t = list[((Aura.idx - 1 + i) % #list) + 1]
                            local p = Payload(t, w, 0)
                            if p and Call("SwordHit", p) then
                                Aura.sent = Aura.sent + 1
                                Aura.last = t.name
                                n = n + 1
                            end
                        end
                        Aura.idx = Aura.idx + n
                        if n > 0 then
                            Call("SwordSwingMiss", { weapon = w, chargeRatio = 0 })
                            if CFG.AuraFace and list[1] then
                                local p = list[1].part.Position
                                pcall(function()
                                    r.CFrame = CFrame.lookAt(r.Position, Vector3.new(p.X, r.Position.Y + 0.001, p.Z))
                                end)
                            end
                            task.wait(math.max(n * 0.02, 0.06))
                        else
                            task.wait(0.06)
                        end
                    end
                end
            end
        end
    end)
end

local function Best(maxD, fov)
    local cam = Cam()
    local cp = cam.CFrame.Position
    local look = cam.CFrame.LookVector
    local best, bs = nil, math.huge
    for _, t in ipairs(Targets()) do
        if t.dist <= maxD and t.part and t.part.Parent then
            local d = t.part.Position - cp
            if d.Magnitude > 0.01 then
                local dot = math.clamp(look:Dot(d.Unit), -1, 1)
                local ang = math.deg(math.acos(dot))
                if ang <= fov then
                    local sc = ang * 2 + t.dist * 0.02
                    if sc < bs then
                        bs = sc
                        best = t
                    end
                end
            end
        end
    end
    return best
end

local function Aimbot()
    if not CFG.Aimbot then
        return
    end
    local t = Best(CFG.EspDist, CFG.AimbotFov)
    if not t then
        return
    end
    local cam = Cam()
    local goal = CFrame.lookAt(cam.CFrame.Position, t.part.Position)
    local a = math.clamp(1 - CFG.AimbotSmooth, 0.05, 1)
    pcall(function()
        cam.CFrame = cam.CFrame:Lerp(goal, a)
    end)
end

local function SilentTick()
    if not CFG.Silent then
        SilentT = nil
        return
    end
    SilentT = Best(CFG.EspDist, 360)
end

local function ProjAim()
    if not CFG.ProjAim then
        return
    end
    local t = Best(CFG.EspDist, CFG.AimbotFov)
    if not t then
        return
    end
    local cam = Cam()
    pcall(function()
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, t.part.Position)
    end)
end

local function Drops()
    return Workspace:FindFirstChild("ItemDrops")
end

local function Pickup()
    local r = Root()
    local f = Drops()
    if not r or not f then
        return
    end
    local org = r.Position
    local now = os.clock()
    local n = 0
    for _, o in ipairs(f:GetChildren()) do
        local p = PartOf(o)
        if p then
            local ct = o:GetAttribute("ClientDropTime")
            if not ct or now - ct > 2 then
                if (p.Position - org).Magnitude <= CFG.PickupRange then
                    Call("PickupItemDrop", { itemDrop = o })
                    n = n + 1
                    if n >= 8 then
                        return
                    end
                end
            end
        end
    end
end

local function Gen()
    local r = Root()
    local f = Drops()
    if not r or not f then
        return
    end
    local org = r.Position
    local mine = MyTeam()
    local n = 0
    for _, o in ipairs(f:GetChildren()) do
        local p = PartOf(o)
        if p and (p.Position - org).Magnitude <= 120 then
            local tm = o:GetAttribute("Team")
            if tm == nil or mine == nil or tm == mine then
                Call("BedwarsUpgradeGenerator", o)
                n = n + 1
                if n >= 4 then
                    return
                end
            end
        end
    end
end

local function SlotOf(o)
    local t = o:GetAttribute("ArmorType") or o:GetAttribute("armorType")
    if type(t) == "string" then
        local u = string.upper(t)
        if string.find(u, "HELM", 1, true) or string.find(u, "HAT", 1, true) then
            return 0
        end
        if string.find(u, "CHEST", 1, true) or string.find(u, "BODY", 1, true) then
            return 1
        end
        if string.find(u, "BOOT", 1, true) or string.find(u, "LEG", 1, true) then
            return 2
        end
    end
    local n = string.lower(o.Name)
    if string.find(n, "helmet", 1, true) or string.find(n, "hat", 1, true) then
        return 0
    end
    if string.find(n, "chest", 1, true) or string.find(n, "plate", 1, true) then
        return 1
    end
    if string.find(n, "boot", 1, true) or string.find(n, "leg", 1, true) then
        return 2
    end
end

local function Armor()
    local inv = Inv()
    if not inv then
        return
    end
    local best = {}
    for _, o in ipairs(inv:GetChildren()) do
        if o:IsA("Tool") or o:IsA("Accessory") then
            local s = SlotOf(o)
            if s then
                local tier = o:GetAttribute("ArmorTier") or o:GetAttribute("Tier") or 1
                if not best[s] or tier > best[s].tier then
                    best[s] = { tool = o, tier = tier }
                end
            end
        end
    end
    for s = 0, 2 do
        if best[s] then
            Call("SetArmorInvItem", { item = best[s].tool, armorSlot = s })
            task.wait(0.05)
        end
    end
end

local SHOP = { "wood_sword", "stone_sword", "iron_sword", "diamond_sword" }

local function Shop()
    for _, it in ipairs(SHOP) do
        Call("BedwarsPurchaseItem", {
            shopItem = { itemType = it, price = 0, currency = "iron" },
            shopId = "item_shop",
        })
        task.wait(0.08)
    end
end

local function AutoTool()
    local inv = Inv()
    if not inv then
        return
    end
    local best
    for _, o in ipairs(inv:GetChildren()) do
        if o:IsA("Tool") then
            local n = string.lower(o.Name)
            if string.find(n, "pickaxe", 1, true) or string.find(n, "pick", 1, true) then
                local tier = o:GetAttribute("ToolTier") or o:GetAttribute("Tier") or 1
                if not best or tier > best.tier then
                    best = { tool = o, tier = tier }
                end
            end
        end
    end
    if best then
        Equip(best.tool)
    end
end

local CONSUME_KEY = { "apple", "golden_apple", "speed", "shield", "potion" }

local function Consume()
    local inv = Inv()
    local c = Char()
    if not inv or not c then
        return
    end
    local h, mx = HP(c)
    if not h or not mx then
        return
    end
    local wantHeal = h / mx * 100 < CFG.ConsumeHp
    for _, o in ipairs(inv:GetChildren()) do
        if o:IsA("Tool") or o:IsA("Accessory") then
            local n = string.lower(o.Name)
            local hit = false
            for _, k in ipairs(CONSUME_KEY) do
                if string.find(n, k, 1, true) then
                    hit = true
                    break
                end
            end
            if hit then
                local isHeal = string.find(n, "apple", 1, true) ~= nil
                if (isHeal and wantHeal) or (not isHeal) then
                    Call("ConsumeItem", { item = o })
                    task.wait(0.15)
                    return
                end
            end
        end
    end
end

local function ChestSteal()
    local c = Char()
    if not c then
        return
    end
    local folder = c:FindFirstChild("ObservedChestFolder")
    if not folder or not folder:IsA("ObjectValue") then
        return
    end
    local chest = folder.Value
    if not chest then
        return
    end
    local n = 0
    for _, o in ipairs(chest:GetChildren()) do
        if o:IsA("Tool") or o:IsA("Accessory") then
            Call("Inventory/ChestGetItem", chest, o)
            n = n + 1
            if n >= 6 then
                return
            end
        end
    end
end

local function VoidDrop()
    local c = Char()
    if not c or not c.PrimaryPart then
        return
    end
    if c.PrimaryPart.Position.Y > -40 then
        return
    end
    local h = Hand()
    if h then
        Call("DropItem", { item = h })
    end
end

local AfkAt = 0

local function AntiAfk()
    local now = os.clock()
    if now - AfkAt < 60 then
        return
    end
    AfkAt = now
    Call("AfkStatus", { afk = false })
end

local function Speed(v)
    local h = Hum()
    if h then
        pcall(function()
            h.WalkSpeed = v
        end)
    end
end

local Rescue = { on = false, target = nil, ground = nil, tries = 0 }

local function FindGround(from, radius)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local c = Char()
    params.FilterDescendantsInstances = c and { c, Cam() } or { Cam() }
    params.RespectCanCollide = true
    local best, bestD = nil, math.huge
    local ok = pcall(function()
        for r = 0, radius, 3 do
            local steps = r == 0 and 1 or 16
            for i = 0, steps - 1 do
                local ang = (i / steps) * math.pi * 2
                local p = from + Vector3.new(math.cos(ang) * r, 0, math.sin(ang) * r)
                local ray = Workspace:Raycast(p + Vector3.new(0, 40, 0), Vector3.new(0, -300, 0), params)
                if ray then
                    local d = (ray.Position - from).Magnitude
                    if d < bestD then
                        bestD = d
                        best = ray.Position
                    end
                end
            end
        end
    end)
    if not ok then
        return nil
    end
    return best
end

local function Grounded()
    local h = Hum()
    if not h then
        return true
    end
    if h.FloorMaterial ~= Enum.Material.Air then
        return true
    end
    local st = h:GetState()
    if st == Enum.HumanoidStateType.Landed or st == Enum.HumanoidStateType.Running
        or st == Enum.HumanoidStateType.RunningNoPhysics then
        return true
    end
    return false
end

local function RescueStep()
    local c = Char()
    local r = c and c.PrimaryPart
    if not r then
        Rescue.on = false
        Rescue.target = nil
        return
    end
    if Grounded() then
        Rescue.on = false
        Rescue.target = nil
        Rescue.ground = nil
        Rescue.tries = 0
        return
    end
    Rescue.tries = Rescue.tries + 1
    if Rescue.tries % 20 == 1 then
        Rescue.ground = FindGround(r.Position, 27)
        if Rescue.ground then
            Rescue.target = Rescue.ground + Vector3.new(0, 4, 0)
        end
    end
    local tgt = Rescue.target
    if not tgt then
        SetVel(r, Vector3.new(r.AssemblyLinearVelocity.X, 90, r.AssemblyLinearVelocity.Z))
        return
    end
    local delta = tgt - r.Position
    local flat = Vector3.new(delta.X, 0, delta.Z)
    local up = math.clamp(delta.Y * 6 + 30, 10, 130)
    local hv = Vector3.zero
    if flat.Magnitude > 0.5 then
        hv = flat.Unit * math.min(flat.Magnitude * 3, 34)
    end
    SetVel(r, Vector3.new(hv.X, up, hv.Z))
end

local function AntiFallTick()
    if not CFG.AntiFall then
        Rescue.on = false
        Rescue.target = nil
        return
    end
    local c = Char()
    local r = c and c.PrimaryPart
    if not r then
        Rescue.on = false
        Rescue.target = nil
        return
    end
    if Rescue.on then
        RescueStep()
        return
    end
    if Grounded() then
        return
    end
    local y = r.Position.Y
    local falling = r.AssemblyLinearVelocity.Y < -8
    local low = y < CFG.AntiFallY
    local noGround = FindGround(r.Position, 6) == nil
    if not (low or (falling and noGround)) then
        return
    end
    Rescue.ground = FindGround(r.Position, 27)
    Rescue.target = Rescue.ground and (Rescue.ground + Vector3.new(0, 4, 0)) or nil
    Rescue.on = true
    Rescue.tries = 0
    RescueStep()
end

local MILESTONE = {
    "GoldLuckyCrate", "OwlKit", "TaliyahKit", "FreeKitSlot",
    "DiamondLuckyCrate_0", "DiamondLuckyCrate_1", "HeroTitle",
    "AngelWings", "CyanAngelWings", "AngelWingWinEffect",
    "AngelWingWinEffect3", "InfernalWhisper", "MythicDaggerLobbyGadget",
}

local function ClaimAll()
    for _, id in ipairs(MILESTONE) do
        Call("ClaimMilestoneReward", id)
        task.wait(0.04)
    end
    Call("ClaimAchievementRewards")
    task.wait(0.05)
    Call("Event_ClaimMission")
    task.wait(0.05)
    Call("ClaimAnniversaryRewards")
    task.wait(0.05)
    Call("TryToClaimGlobalTeamReward")
    task.wait(0.05)
    Call("TryToClaimGlobalTimedGoalReward")
end

local LMAP = {
    { "EmoteType", "Locker/SetEmote", "emote", true },
    { "TitleType", "Locker/SetTitle", "title" },
    { "LobbyGadget", "Locker/SetLobbyGadget", "lobbyGadget" },
    { "Pet", "Locker/SetPet", "pet" },
    { "WinEffect", "Locker/SetWinEffect", "winEffect" },
    { "BedBreakEffect", "Locker/SetBreakBedEffect", "breakBedEffect" },
    { "KillEffect", "Locker/SetKillEffect", "killEffect" },
    { "Badges", "Locker/SetFeaturedBadge", "badge" },
    { "BedSkin", "Locker/SetBedSkin", "bedSkin" },
}

local Busy = false

local function IdOf(v)
    if type(v) == "table" then
        return v.id or v.itemId or v.name or v.itemType
    end
    return tostring(v)
end

local function Unlock()
    if Busy then
        return
    end
    Busy = true
    for _, d in ipairs(LMAP) do
        local ok, items = Call("Locker/GetLockerCategoryItems", d[1])
        if ok and type(items) == "table" then
            local slot = 1
            for _, it in ipairs(items) do
                local id = IdOf(it)
                if id and id ~= "" then
                    local a
                    if d[4] then
                        a = { [d[3]] = id, slot = slot }
                        slot = slot % 8 + 1
                    else
                        a = { [d[3]] = id }
                    end
                    Call(d[2], a)
                    task.wait(0.03)
                end
            end
        end
    end
    local okS, skins = Call("Locker/GetLockerCategoryItems", "ItemSkin")
    if okS and type(skins) == "table" then
        for _, it in ipairs(skins) do
            if type(it) == "table" and it.itemType then
                Call("Locker/SetItemSkin", { itemType = it.itemType, itemSkin = IdOf(it) })
                task.wait(0.03)
            end
        end
    end
    Busy = false
end

local TORDER = {
    { "Aura", "杀戮光环" },
    { "Silent", "静默瞄准" },
    { "Aimbot", "视角自瞄" },
    { "ProjAim", "弹道自瞄" },
    { "EspPlayer", "ESP 玩家" },
    { "EspNpc", "ESP NPC" },
    { "EspDummy", "ESP 训练场人机" },
    { "BedEsp", "床透视" },
    { "BedPlate", "床顶浮字" },
    { "StorageEsp", "容器透视" },
    { "KitEsp", "道具透视" },
    { "HealthHud", "屏幕血量" },
    { "Pickup", "自动拾取" },
    { "Gen", "自动生成器" },
    { "Armor", "自动护甲" },
    { "Shop", "自动商店" },
    { "Tool", "自动换工具" },
    { "Consume", "自动吃药" },
    { "ChestSteal", "自动开箱" },
    { "VoidDrop", "掉落丢弃" },
    { "AntiAfk", "防踢" },
    { "Claim", "自动领奖" },
    { "Speed", "加速" },
    { "AntiFall", "防掉落" },
}

local TLast = ""

local function TickerSync()
    local l = {}
    for _, it in ipairs(TORDER) do
        if CFG[it[1]] then
            l[#l + 1] = it[2]
        end
    end
    if CFG.TickerTarget and CFG.Aura and Aura.last ~= "-" then
        l[#l + 1] = "→ " .. Aura.last
    end
    local txt = table.concat(l, "|")
    if txt == TLast then
        return
    end
    TLast = txt
    if not CFG.Ticker then
        l = {}
    end
    local ds = UI.DS
    if ds and ds.Ticker and ds.Ticker.Set then
        pcall(function()
            ds.Ticker.Set(l)
        end)
    end
end

local function Flag(k, v)
    CFG[k] = v
    TickerSync()
end

local Tasks = {
    { 0.05, EspTick },
    { 0.10, BedTick },
    { 0.30, ChestTick },
    { 0.50, KitTick },
    { 0.10, HudTick },
    { 0.03, Aimbot },
    { 0.06, SilentTick },
    { 0.04, ProjAim },
    { 0.40, Pickup, "Pickup" },
    { 2.00, Gen, "Gen" },
    { 1.00, Armor, "Armor" },
    { 3.00, Shop, "Shop" },
    { 0.50, AutoTool, "Tool" },
    { 0.50, Consume, "Consume" },
    { 0.25, ChestSteal, "自动开箱" },
    { 0.50, VoidDrop, "VoidDrop" },
    { 5.00, AntiAfk, "AntiAfk" },
    { 0.10, function()
        Speed(CFG.SpeedVal)
    end, "Speed" },
}

local Acc = {}
for i = 1, #Tasks do
    Acc[i] = 0
end

local ClaimAt = 0
local TickAcc = 0

local function Loop(dt)
    for i, t in ipairs(Tasks) do
        Acc[i] = Acc[i] + dt
        if Acc[i] >= t[1] then
            Acc[i] = 0
            if t[3] == nil or CFG[t[3]] then
                pcall(t[2])
            end
        end
    end
    if CFG.Claim then
        local now = os.clock()
        if now - ClaimAt >= CFG.ClaimGap then
            ClaimAt = now
            pcall(ClaimAll)
        end
    end
    TickAcc = TickAcc + dt
    if TickAcc >= 0.5 then
        TickAcc = 0
        pcall(TickerSync)
    end
end

pcall(function()
    game:BindToClose(function()
        Wipe(Esp.cache)
        Wipe(Bed.cache)
        Wipe(Bed.plate)
        Wipe(Chest.cache)
        Wipe(Kit.cache)
        pcall(Speed, 16)
    end)
end)

HookSilent()
HitRemote = R("SwordHit")
AuraLoop()

local Drag = nil

local function SliderSet(s, x)
    local tr = s.UIElements and s.UIElements.Track
    if not tr then
        return
    end
    local w = tr.AbsoluteSize.X
    if w <= 0 then
        return
    end
    local r = math.clamp((x - tr.AbsolutePosition.X) / w, 0, 1)
    s:Set(s.Value.Min + r * (s.Value.Max - s.Value.Min))
end

local function Bind(s)
    local hit = s and s.UIElements and s.UIElements.Input
    if not hit then
        return s
    end
    hit.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
            Drag = s
            SliderSet(s, input.Position.X)
        end
    end)
    return s
end

UIS.InputChanged:Connect(function(input)
    if not Drag then
        return
    end
    local t = input.UserInputType
    if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseMovement then
        SliderSet(Drag, input.Position.X)
    end
end)

UIS.InputEnded:Connect(function(input)
    if not Drag then
        return
    end
    local t = input.UserInputType
    if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
        SliderSet(Drag, input.Position.X)
        Drag = nil
    end
end)

local OK, ERR = pcall(function()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    local url = "https://raw.githubusercontent.com/lIllIIlII/NEW/refs/heads/main/deepseek-ui/main.lua?cb=" .. tostring(os.time())
    local src
    for _, fn in ipairs({ function() return game:HttpGet(url) end, function() return game:HttpGetAsync(url) end }) do
        local ok, v = pcall(fn)
        if ok and type(v) == "string" and #v > 1000 then
            src = v
            break
        end
    end
    assert(src, "library download failed")
    local ch = loadstring(src, "DeepSeekUI/main")
    assert(type(ch) == "function", "library compile failed")
    local lib = ch()
    assert(type(lib) == "table", "library returned non-table")

    local W = lib
    local DS = W.DeepSeek or {}
    UI.DS = DS

    local Win = W:CreateWindow({
        Title = "DeepSeek",
        Icon = "ds:logo",
        Author = "DeepSeek AI",
        Folder = "DeepSeekBW",
        Size = UDim2.fromOffset(620, 450),
        MinSize = Vector2.new(520, 340),
        MaxSize = Vector2.new(900, 640),
        Transparent = false,
        Theme = "Dark",
        HideSearchBar = true,
        ScrollBarEnabled = true,
        SideBarWidth = 168,
        Acrylic = false,
        User = { Enabled = false, Anonymous = false },
    })

    local Group = "Combat"
    local dirs = setmetatable({}, { __mode = "k" })
    local errs = {}

    local function C(parent, kind, props)
        if not parent then
            return nil
        end
        props = props or {}
        if kind == "Section" then
            if props.Opened == nil then props.Opened = true end
            if props.Box == nil then props.Box = false end
        end
        local tgt = (kind == "Section" or kind == "Group" or kind == "HStack" or kind == "VStack")
            and parent or (dirs[parent] or parent)
        local fn = tgt[kind]
        if type(fn) ~= "function" then
            errs[#errs + 1] = kind .. ": missing"
            return nil
        end
        local ok, res = pcall(fn, tgt, props)
        if not ok or not res then
            errs[#errs + 1] = kind .. ": " .. tostring(res)
            return nil
        end
        if kind == "Section" then
            dirs[parent] = res
        end
        if props.Title and kind ~= "Section" and DS.RegisterJump then
            DS.RegisterJump(props.Title, res, Group)
        end
        return res
    end

    local function Tog(parent, title, key, cb)
        return C(parent, "Toggle", {
            Title = title,
            Value = CFG[key],
            Callback = cb or function(v) Flag(key, v) end,
        })
    end

    local function Sld(parent, title, step, min, max, key, cb)
        local s = C(parent, "Slider", {
            Title = title,
            Step = step,
            Width = 200,
            IsTextbox = false,
            Value = { Min = min, Max = max, Default = CFG[key] },
            Callback = cb or function(v) CFG[key] = v end,
        })
        return Bind(s)
    end

    pcall(function()
        Win:Tag({ Title = "", Icon = "ds:lockup", Height = 30, IconWidth = 126, IconHeight = 21 })
    end)

    local Combat = Win:Tab({ Title = "战斗", Icon = "lucide:swords" })
    local Visual = Win:Tab({ Title = "视觉", Icon = "lucide:eye" })
    local Auto = Win:Tab({ Title = "自动", Icon = "lucide:bot" })
    local Reward = Win:Tab({ Title = "奖励", Icon = "lucide:gift" })
    local Settings = Win:Tab({ Title = "设置", Icon = "lucide:settings" })

    Group = "Combat"
    C(Combat, "Section", { Title = "近战" })
    Tog(Combat, "杀戮光环", "Aura")
    Sld(Combat, "光环范围", 0.5, 4, 20, "AuraRange")
    Sld(Combat, "最大目标数", 1, 1, 8, "AuraMax")
    Sld(Combat, "攻击角度", 10, 30, 360, "AuraAngle")
    Tog(Combat, "自动转向", "AuraFace")

    C(Combat, "Section", { Title = "瞄准" })
    Tog(Combat, "静默瞄准", "Silent")
    Tog(Combat, "视角自瞄", "Aimbot")
    Tog(Combat, "弹道自瞄", "ProjAim")
    Sld(Combat, "自瞄 FOV", 5, 20, 360, "AimbotFov")
    Sld(Combat, "平滑度", 0.05, 0, 0.9, "AimbotSmooth")
    Tog(Combat, "队伍检测", "Team")

    Group = "Visual"
    C(Visual, "Section", { Title = "ESP" })
    Tog(Visual, "ESP 玩家", "EspPlayer")
    Tog(Visual, "ESP 怪物", "EspNpc")
    Tog(Visual, "ESP 训练场人机", "EspDummy")
    Tog(Visual, "显示血量", "EspHp")
    Tog(Visual, "显示手持物品", "EspItem")
    Sld(Visual, "ESP 距离", 50, 50, 2000, "EspDist")

    C(Visual, "Section", { Title = "世界" })
    Tog(Visual, "床透视", "BedEsp")
    Tog(Visual, "床顶浮字", "BedPlate")
    Tog(Visual, "容器透视", "StorageEsp")
    Tog(Visual, "道具透视", "KitEsp")
    Tog(Visual, "屏幕血量", "HealthHud")

    Group = "Auto"
    C(Auto, "Section", { Title = "资源" })
    Tog(Auto, "自动拾取", "Pickup")
    Sld(Auto, "拾取范围", 5, 10, 200, "PickupRange")
    Tog(Auto, "自动生成器", "Gen")
    Tog(Auto, "自动护甲", "Armor")
    Tog(Auto, "自动商店", "Shop")
    Tog(Auto, "自动换工具", "Tool")

    C(Auto, "Section", { Title = "库存" })
    Tog(Auto, "自动吃药", "Consume")
    Sld(Auto, "吃药血量", 1, 1, 99, "ConsumeHp")
    Tog(Auto, "自动开箱", "ChestSteal")
    Tog(Auto, "掉落丢弃", "VoidDrop")

    C(Auto, "Section", { Title = "移动" })
    Tog(Auto, "加速", "Speed", function(v)
        CFG.Speed = v
        if not v then
            pcall(Speed, 16)
        end
        TickerSync()
    end)
    Sld(Auto, "速度值", 2, 16, 200, "SpeedVal")
    Tog(Auto, "防掉落", "AntiFall")
    Sld(Auto, "坠落阈值", 1, -80, 0, "AntiFallY")
    Tog(Auto, "防踢", "AntiAfk")

    Group = "Reward"
    C(Reward, "Section", { Title = "领取" })
    C(Reward, "Button", {
        Title = "领取全部",
        Callback = function()
            task.spawn(ClaimAll)
        end,
    })
    Tog(Reward, "自动领奖", "Claim")
    Sld(Reward, "领取间隔", 5, 10, 300, "ClaimGap")
    C(Reward, "Section", { Title = "解锁" })
    C(Reward, "Button", {
        Title = "全解锁",
        Callback = function()
            task.spawn(Unlock)
        end,
    })

    Group = "Settings"
    C(Settings, "Section", { Title = "主题" })
    C(Settings, "Dropdown", {
        Title = "配色",
        Values = { "Dark", "Light", "Rose", "Plant", "Red", "Indigo", "Sky", "Violet", "Amber", "Emerald", "Midnight", "Crimson", "Mellowsi", "Rainbow" },
        Value = CFG.Theme,
        SearchBarEnabled = true,
        Callback = function(v)
            local name = type(v) == "table" and v[1] or v
            CFG.Theme = name
            pcall(function()
                W:SetTheme(name)
            end)
        end,
    })
    C(Settings, "Colorpicker", {
        Title = "强调色",
        Default = Color3.fromHex("#4D6BFE"),
        Callback = function(c)
            if DS.SetPalette then
                pcall(function()
                    DS.SetPalette(c)
                end)
            end
        end,
    })

    C(Settings, "Section", { Title = "走马灯" })
    Tog(Settings, "显示走马灯", "Ticker", function(v)
        CFG.Ticker = v
        TLast = ""
        TickerSync()
    end)
    Tog(Settings, "显示目标名", "TickerTarget", function(v)
        CFG.TickerTarget = v
        TLast = ""
        TickerSync()
    end)

    C(Settings, "Section", { Title = "桌宠贴纸" })
    for _, p in ipairs({
        { "pet", "侧边桌宠" },
        { "sitter", "顶部桌宠" },
        { "sticker", "贴纸" },
        { "sheen", "扫光" },
        { "glow", "辉光" },
        { "bg", "背景板" },
        { "ticker", "走马灯条" },
    }) do
        C(Settings, "Toggle", {
            Title = p[2],
            Value = true,
            Callback = function(v)
                if DS.SetPart then
                    pcall(function()
                        DS.SetPart(p[1], v)
                    end)
                end
            end,
        })
    end

    C(Settings, "Section", { Title = "字体" })
    local fontList = DS.Fonts and DS.Fonts() or {}
    if #fontList > 0 then
        C(Settings, "Dropdown", {
            Title = "字体家族",
            Values = fontList,
            Value = fontList[1],
            SearchBarEnabled = true,
            Callback = function(v)
                local n = type(v) == "table" and (v.Title or v[1]) or v
                if DS.SetFont then
                    pcall(function()
                        DS.SetFont(n)
                    end)
                end
            end,
        })
    end
    Sld(Settings, "字号比例", 1, 70, 150, "FontScale", function(v)
        if DS.SetFontScale then
            pcall(function()
                DS.SetFontScale(v / 100)
            end)
        end
    end)

    C(Settings, "Section", { Title = "声音" })
    C(Settings, "Toggle", {
        Title = "欢迎音效",
        Value = true,
        Callback = function(v)
            if DS.SetPart then
                pcall(function()
                    DS.SetPart("sound", v)
                end)
            end
        end,
    })
    C(Settings, "Button", {
        Title = "重播欢迎音",
        Callback = function()
            if DS.PlaySound then
                pcall(function()
                    DS.PlaySound(0.6)
                end)
            end
        end,
    })

    C(Settings, "Section", { Title = "调试" })
    C(Settings, "Button", {
        Title = "打印状态",
        Callback = function()
            print("[DS] net", NM() ~= nil, "hit", R("SwordHit") ~= nil)
            print("[DS] targets", #Targets(), "hand", Hand() and Hand().Name or "nil")
            print("[DS] aura", Aura.sent, Aura.last, "rescue", Rescue.on)
        end,
    })

    if #errs > 0 then
        warn("[DS] ui errors:\n" .. table.concat(errs, "\n"))
    end

    pcall(function()
        Win:SelectTab(Combat)
    end)
    TLast = ""
    TickerSync()
end)

if not OK then
    warn("[DS] ui load failed: " .. tostring(ERR))
end

local Last = os.clock()
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    local dt = now - Last
    Last = now
    if dt > 2.4 then
        return
    end
    pcall(Loop, dt)
end)

RunService.PreSimulation:Connect(function()
    pcall(AntiFallTick)
end)