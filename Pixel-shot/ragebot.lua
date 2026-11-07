local P=game:GetService("Players")
local R=game:GetService("RunService")
local W=game:GetService("Workspace")
local T=game:GetService("TweenService")
local D=game:GetService("Debris")
local S=game:GetService("SoundService")
local RS=game:GetService("ReplicatedStorage")
local LP=P.LocalPlayer
local RA=RS:WaitForChild("SystemResources"):WaitForChild("BufferCache"):WaitForChild("RequestActionSync")
local PE=RS:WaitForChild("Modules"):WaitForChild("KillPrediction"):WaitForChild("PredictedEvent")
local FB=RS:WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("ReplicateFakeBullet")

local RANGE=1000
local SPD=900
local INT=0.09
local PRED=0.35
local FOV=360
local HEAD=true
local SND="rbxassetid://8679627751"
local C1=Color3.fromRGB(0,255,100)
local C2=Color3.fromRGB(160,255,200)

local T0=tick()
local F0=T0-28800
local LAST=0

local function trail(a,b)
	local d=(b-a).Magnitude
	if d<0.2 then return end
	local dir=(b-a)/d
	local perp=Vector3.new(-dir.Z,0,dir.X)
	if perp.Magnitude<1e-3 then perp=Vector3.new(1,0,0) end
	perp=perp.Unit
	local up=dir:Cross(perp).Unit
	local n=math.clamp(math.floor(d/4),3,40)
	local fr=math.random(3,6)
	local am=math.random(6,16)/1000
	local ph=math.random()*6.283
	local pts={}
	for i=0,n do
		local t=i/n
		pts[i+1]=a+dir*d*t+up*math.sin(t*math.pi*fr+ph)*d*am+perp*math.sin(t*math.pi*(fr+1.5))*d*am*0.5
	end
	local f=Instance.new("Folder")
	f.Name="RageTracer"
	f.Parent=W.Terrain
	for i=1,n do
		local p0=pts[i]
		local p1=pts[i+1]
		local sd=(p1-p0).Magnitude
		if sd>0.01 then
			local g=Instance.new("Part")
			g.Anchored=true
			g.CanCollide=false
			g.CanQuery=false
			g.CanTouch=false
			g.Material=Enum.Material.Neon
			g.Color=C1
			g.Size=Vector3.new(0.14,0.14,sd)
			g.CFrame=CFrame.lookAt(p0,p1)*CFrame.new(0,0,-sd/2)
			g.Transparency=0.15
			g.Parent=f
			task.delay(0.16+i/n*0.06,function()
				if g.Parent then T:Create(g,TweenInfo.new(0.22),{Transparency=1}):Play() end
			end)
		end
	end
	task.delay(0.62,function() if f.Parent then f:Destroy() end end)
end

local function impact(p)
	local f=Instance.new("Folder")
	f.Name="RageHit"
	f.Parent=W.Terrain
	local b=Instance.new("Part")
	b.Anchored=true
	b.CanCollide=false
	b.CanQuery=false
	b.CanTouch=false
	b.Material=Enum.Material.Neon
	b.Color=C2
	b.Shape=Enum.PartType.Ball
	b.Size=Vector3.new(0.35,0.35,0.35)
	b.Position=p
	b.Parent=f
	local l=Instance.new("PointLight")
	l.Color=C2
	l.Brightness=10
	l.Range=24
	l.Parent=b
	local e=Instance.new("ParticleEmitter")
	e.Texture="rbxassetid://258128463"
	e.Color=ColorSequence.new(C2)
	e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.9),NumberSequenceKeypoint.new(1,0)})
	e.Transparency=NumberSequence.new(0,1)
	e.Lifetime=NumberRange.new(0.25,0.5)
	e.Speed=NumberRange.new(14,28)
	e.SpreadAngle=Vector2.new(180,180)
	e.Rate=0
	e.Parent=b
	e:Emit(24)
	T:Create(b,TweenInfo.new(0.35,Enum.EasingStyle.Exponential),{Size=Vector3.new(2,2,2),Transparency=1}):Play()
	T:Create(l,TweenInfo.new(0.3),{Brightness=0}):Play()
	task.delay(0.7,function() if f.Parent then f:Destroy() end end)
end

local function hsnd()
	local s=Instance.new("Sound")
	s.SoundId=SND
	s.Volume=0.9
	s.Parent=S
	s:Play()
	D:AddItem(s,2)
end

local function pool()
	local t={}
	for _,pl in ipairs(P:GetPlayers()) do
		if pl~=LP and pl.Character then t[#t+1]=pl.Character end
	end
	local bc=W:FindFirstChild("BotCharacters")
	if bc then
		for _,m in ipairs(bc:GetChildren()) do
			if m:IsA("Model") and m~=LP.Character then t[#t+1]=m end
		end
	end
	return t
end

local function aim(c)
	local h=c:FindFirstChild("Head")
	local r=c:FindFirstChild("HumanoidRootPart")
	if HEAD and h then return h,h.Position end
	if r then return r,r.Position end
	if h then return h,h.Position end
end

local function shot()
	local ch=LP.Character
	if not ch then return end
	local cam=W.CurrentCamera
	if not cam then return end
	local o=cam.CFrame.Position
	local fwd=cam.CFrame.LookVector
	local list=pool()
	local best,bs,bp
	for _,c in ipairs(list) do
		local hum=c:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health>0 then
			local pt,pos=aim(c)
			if pt then
				local rel=pos-o
				local d=rel.Magnitude
				if d<=RANGE and d>0.1 then
					local ang=math.deg(math.acos(math.clamp(fwd:Dot(rel/d),-1,1)))
					if ang<=FOV then
						local rp=RaycastParams.new()
						rp.FilterType=Enum.RaycastFilterType.Exclude
						rp.FilterDescendantsInstances={ch,c}
						if not W:Raycast(o,rel,rp) then
							local sc=ang+d*0.02
							if not bs or sc<bs then
								bs=sc
								best=c
								bp=pos
							end
						end
					end
				end
			end
		end
	end
	if not best then return end
	local r=best:FindFirstChild("HumanoidRootPart")
	local v=r and r.AssemblyLinearVelocity or Vector3.zero
	local d=(bp-o).Magnitude
	local dir=(bp+v*(d/SPD)*PRED-o).Unit
	local raw={}
	for _,c in ipairs(list) do
		local hum=c:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health>0 then
			local pt,pos=aim(c)
			if pt then
				local rel=pos-o
				local pj=rel:Dot(dir)
				if pj>0 and pj<RANGE and (rel-dir*pj).Magnitude<=math.max(2.5,pt.Size.Magnitude*0.6) then
					raw[#raw+1]={pj=pj,headshot=(pt==c:FindFirstChild("Head")),humanoid=hum,position=pos,instance=pt,model=c}
				end
			end
		end
	end
	if #raw==0 then return end
	table.sort(raw,function(a,b) return a.pj<b.pj end)
	local ign={ch}
	for _,c in ipairs(list) do ign[#ign+1]=c end
	local rp=RaycastParams.new()
	rp.FilterType=Enum.RaycastFilterType.Exclude
	rp.FilterDescendantsInstances=ign
	local wall=W:Raycast(o,dir*RANGE,rp)
	local hp=o+dir*RANGE
	local hi
	if wall then
		hp=wall.Position
		hi=wall.Instance
	end
	local hits={}
	for _,h in ipairs(raw) do
		hits[#hits+1]={headshot=h.headshot,humanoid=h.humanoid,position=h.position,instance=h.instance,model=h.model}
	end
	RA:FireServer({direction=dir,hitPosition=hp,origin=o,hits=hits,hitInstance=hi or hits[1].instance,fireTime=F0+(tick()-T0)})
	pcall(function()
		PE:Fire({deathPos=hits[1].position,humanoid=hits[1].humanoid,hitPosition=hits[1].position,isHeadshot=hits[1].headshot,isCollateral=#hits>1})
	end)
	pcall(function() FB:FireServer(cam.CFrame,dir,d) end)
	trail(o,hp)
	impact(hp)
	hsnd()
end

R.Heartbeat:Connect(function()
	if tick()-LAST<INT then return end
	LAST=tick()
	pcall(shot)
end)