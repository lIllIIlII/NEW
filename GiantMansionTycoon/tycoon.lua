local P=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local W=game:GetService("Workspace")
local R=game:GetService("RunService")
local LP=P.LocalPlayer

local INTERVAL=0.25 --主循环间隔(s)，越小反应越快
local WITHDRAW_CD=300 --自动取钱间隔(s)，300=5分钟
local PULL=true --是否优先把道具拉到角色身上（true=绕过传送，false=纯瞬移）
local WARP_N=3 --瞬移后等待的物理帧数，网络差可调大
local MAX_FAIL=2 --单个按钮连续失败上限，超过后暂时跳过
local FAIL_TTL=60 --失败记录过期时间(s)，到点自动清除重试
local SETTLE=1.5 --取钱后等待服务器结算的时间(s)，期间不查余额

local function find(f,n)
	for _,i in ipairs(n) do
		local o=f:FindFirstChild(i)
		if o then return o end
	end
end

local RM=find(RS,{"Remotes","Remote","RemotesFolder","RE"}) or RS:WaitForChild("Remote",15)
local CR=RM and RM:WaitForChild("CollectEventRemote",15)
local BQ=RM and RM:WaitForChild("ButtonPurchaseRequested",15)
local MC=RM and RM:WaitForChild("MoneyChanged",15)
local BC=RM and RM:WaitForChild("BankMoneyChanged",15)
local BW=RM and RM:WaitForChild("BankWithdraw",15)
local GD=RM and RM:WaitForChild("GetData",15)
local BX=RM and RM:WaitForChild("ButtonPurchased",15)

local MONEY=0
local BANK=0
local Q={}
local IX=1
local WARM=false
local LASTWD=0
local BUSY=false
local SETTLE_UNTIL=0
local FAILS={}

local function money()
	if not GD then return MONEY end
	if os.clock()<SETTLE_UNTIL then return MONEY end
	local ok,v=pcall(function() return GD:InvokeServer("Money") end)
	if ok then
		if type(v)=="number" then
			MONEY=v
		elseif type(v)=="table" then
			for _,x in ipairs(v) do
				if type(x)=="number" then
					MONEY=x
					break
				end
			end
		end
	end
	return MONEY
end

if MC then
	MC.OnClientEvent:Connect(function(v)
		if type(v)=="number" then MONEY=v end
	end)
end
if BC then
	BC.OnClientEvent:Connect(function(v)
		if type(v)=="number" then BANK=v end
	end)
end
pcall(money)

local function core()
	local c=LP.Character
	if not c then return end
	local h=c:FindFirstChild("Humanoid") or c:FindFirstChildOfClass("Humanoid")
	local r=c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
	return c,h,r
end

local function alive()
	local c,h,r=core()
	if not c or not r then return false end
	if h and h.Health<=0 then return false end
	return true
end

local function warm()
	local c,h,r=core()
	if not c or not h or not r then return false end
	h:ChangeState(Enum.HumanoidStateType.Running)
	h.PlatformStand=false
	h.Sit=false
	h.Jump=false
	r.CanTouch=true
	r.CanCollide=true
	r.Anchored=false
	WARM=true
	return true
end

local function warp(pos,n)
	local c,h,r=core()
	if not c or not r then return false end
	r.CanTouch=true
	r.CanCollide=false
	r.Anchored=false
	pcall(function() c:PivotTo(CFrame.new(pos)) end)
	pcall(function() r.CFrame=CFrame.new(pos) end)
	if h then h:ChangeState(Enum.HumanoidStateType.Running) end
	for i=1,(n or WARP_N) do
		r.CanTouch=true
		R.Heartbeat:Wait()
	end
	return true
end

local function back()
	local _,_,r=core()
	if r then r.CanCollide=true end
end

local function tycoon()
	local f=find(W,{"Tycoons","Tycoon","TycoonsFolder"})
	local l={}
	if f then
		for _,m in ipairs(f:GetChildren()) do l[#l+1]=m end
	else
		for _,m in ipairs(W:GetChildren()) do
			if m:IsA("Model") and m:GetAttribute("Owner")~=nil then l[#l+1]=m end
		end
	end
	for _,m in ipairs(l) do
		if m:GetAttribute("Owner")==LP.Name then return m end
	end
end

local function bank()
	local t=tycoon()
	if not t then return end
	local md=t:FindFirstChild("Models")
	if md then
		local b=md:FindFirstChild("Bank")
		if b then return b end
		for _,x in ipairs(md:GetChildren()) do
			if x.Name:lower():find("bank") then return x end
		end
	end
	for _,x in ipairs(t:GetDescendants()) do
		if x:IsA("Model") and x.Name:lower():find("bank") then return x end
	end
end

local function buttons()
	local l={}
	local t=tycoon()
	if not t then return l end
	local s={}
	local function add(c)
		if not c or s[c] then return end
		s[c]=true
		l[#l+1]=c
	end
	for _,n in ipairs({"Buttons","Button","BuyButtons"}) do
		local b=t:FindFirstChild(n)
		if b then for _,v in ipairs(b:GetChildren()) do add(v) end end
	end
	for _,n in ipairs({"Extensions","Extension"}) do
		local e=t:FindFirstChild(n)
		if e then
			for _,x in ipairs(e:GetChildren()) do
				for _,n2 in ipairs({"Buttons","Button"}) do
					local b=x:FindFirstChild(n2)
					if b then for _,v in ipairs(b:GetChildren()) do add(v) end end
				end
			end
		end
	end
	if #l==0 then
		for _,d in ipairs(t:GetDescendants()) do
			if d:IsA("Model") and d:GetAttribute("Price")~=nil then add(d) end
		end
	end
	return l
end

local function items()
	local ev=find(W,{"Events","Event","CollectEvents"})
	if not ev then return {} end
	local ce=find(ev,{"CollectEvent","CollectEvents","Collectibles"})
	if not ce then return {} end
	return ce:GetChildren()
end

local function posOf(o)
	if not o then return end
	if o:IsA("BasePart") then return o.Position,o end
	local pp=o:FindFirstChild("PrimaryPart") or o.PrimaryPart
	if pp then return pp.Position,pp end
	if o:IsA("Model") then
		local ok,p=pcall(function() return o:GetPivot().Position end)
		if ok then return p end
	end
end

local function grab()
	if not alive() or BUSY then return end
	for _,it in ipairs(items()) do
		local pos,pp=posOf(it)
		if pos and pp then
			pp.CanTouch=true
			pp.CanQuery=false
			if PULL then
				pcall(function()
					local _,_,r=core()
					if r then
						if it:IsA("Model") then
							it:PivotTo(CFrame.new(r.Position))
						else
							it.CFrame=CFrame.new(r.Position)
						end
					end
				end)
				R.Heartbeat:Wait()
				R.Heartbeat:Wait()
			end
			if it.Parent then
				warp(pos+Vector3.new(0,pp.Size.Y*0.5+2.2,0),2)
				if CR then pcall(function() CR:FireServer(it) end) end
				R.Heartbeat:Wait()
			end
			back()
		end
	end
end

local function cleanFails()
	local now=os.clock()
	for k,v in pairs(FAILS) do
		if now-v.t>FAIL_TTL then FAILS[k]=nil end
	end
end

local function refresh()
	Q={}
	for _,b in ipairs(buttons()) do
		local p=b:GetAttribute("Price")
		if type(p)~="number" then p=0 end
		Q[#Q+1]={m=b,p=p}
	end
	table.sort(Q,function(a,b) return a.p<b.p end)
	if IX>#Q then IX=1 end
	if IX<1 then IX=1 end
end

local function buy()
	if not BQ or #Q==0 or not alive() or BUSY then return end
	cleanFails()
	local m=money()
	local n=#Q
	for i=0,n-1 do
		local k=(IX+i-1)%n+1
		local it=Q[k]
		if it.m and it.m:IsDescendantOf(W) then
			local key=it.m.Name.."@"..tostring(it.p)
			local f=FAILS[key]
			if (not f or f.c<MAX_FAIL) and it.p<=m then
				local pos,pp=posOf(it.m)
				if pos and pp then
					local target=it.m
					local id=key
					warp(pos+Vector3.new(0,pp.Size.Y*0.5+2.2,0),2)
					pcall(function() BQ:FireServer(target) end)
					IX=k+1
					task.delay(1.2,function()
						if target and target:IsDescendantOf(W) then
							local c=(FAILS[id] and FAILS[id].c or 0)+1
							FAILS[id]={c=c,t=os.clock()}
						else
							FAILS[id]=nil
						end
					end)
					R.Heartbeat:Wait()
					back()
					return
				end
			end
		end
	end
end

local function withdraw()
	if not BW or BUSY then return end
	if BANK<=0 then return end
	if os.clock()-LASTWD<WITHDRAW_CD then return end
	local b=bank()
	if not b then return end
	local pos=posOf(b)
	if not pos then return end
	BUSY=true
	local amt=BANK
	warp(pos+Vector3.new(0,3,0),3)
	pcall(function() BW:FireServer(amt,b) end)
	MONEY=MONEY+amt
	BANK=0
	LASTWD=os.clock()
	SETTLE_UNTIL=os.clock()+SETTLE
	R.Heartbeat:Wait()
	back()
	task.wait(0.2)
	pcall(refresh)
	BUSY=false
end

if BX then
	BX.OnClientEvent:Connect(function()
		task.defer(refresh)
	end)
end

LP.CharacterAdded:Connect(function()
	WARM=false
	FAILS={}
	BUSY=false
	task.wait(1)
	pcall(warm)
	pcall(refresh)
end)

task.spawn(function()
	task.wait(1.5)
	pcall(warm)
	pcall(refresh)
	LASTWD=os.clock()-WITHDRAW_CD
	while true do
		if alive() then
			if not WARM then pcall(warm) end
			pcall(grab)
			if #Q==0 then pcall(refresh) end
			pcall(buy)
			pcall(withdraw)
		else
			WARM=false
		end
		task.wait(INTERVAL)
	end
end)