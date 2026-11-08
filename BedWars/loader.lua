local isfile = isfile or function(f)
    local ok, r = pcall(function()
        return readfile(f)
    end)
    return ok and r ~= nil and r ~= ""
end

local isfolder = isfolder or function(f)
    local ok, r = pcall(function()
        return listfiles(f)
    end)
    return ok and r ~= nil
end

local makefolder = makefolder or function() end
local writefile = writefile or function() end
local delfile = delfile or function(f)
    writefile(f, "")
end
local listfiles = listfiles or function()
    return {}
end

local RAW = "https://raw.githubusercontent.com/lIllIIlII/NEW/refs/heads/main/BedWars"
local BASE = "DeepSeekBW"
local ASSET_VER = "1"
local WM = "--dswm"

local function http(url)
    for _, fn in ipairs({
        function() return game:HttpGet(url, true) end,
        function() return game:HttpGet(url) end,
        function() return game:HttpGetAsync(url) end,
    }) do
        local ok, r = pcall(fn)
        if ok and type(r) == "string" and #r > 64 then
            return r
        end
    end
end

local function ensureDir(p)
    if not isfolder(p) then
        pcall(makefolder, p)
    end
end

local function wipe(p)
    if not isfolder(p) then
        return
    end
    local ok, files = pcall(listfiles, p)
    if not ok or not files then
        return
    end
    for _, f in ipairs(files) do
        if not string.find(f, "loader", 1, true) then
            local ok2, c = pcall(readfile, f)
            if ok2 and type(c) == "string" and string.sub(c, 1, #WM) == WM then
                pcall(delfile, f)
            end
        end
    end
end

local function fetch(name, force)
    local path = BASE .. "/" .. name
    if force or not isfile(path) then
        local url = RAW .. "/" .. name .. "?v=" .. ASSET_VER
        local body = http(url)
        if not body then
            if isfile(path) then
                return readfile(path)
            end
            error("download failed: " .. name)
        end
        if string.find(name, ".lua", 1, true) then
            body = WM .. "\n" .. body
        end
        pcall(writefile, path, body)
    end
    return readfile(path)
end

ensureDir(BASE)

local verPath = BASE .. "/.ver"
local oldVer
pcall(function()
    oldVer = readfile(verPath)
end)
if oldVer ~= ASSET_VER then
    wipe(BASE)
    pcall(writefile, verPath, ASSET_VER)
end

local src = fetch("BedWars.lua", true)
local chunk, err = loadstring(src, "DeepSeekBW")
if not chunk then
    error("[DeepSeekBW] compile failed: " .. tostring(err))
end
return chunk()