-- Build 80 demo: native root tabs only; no custom nested page system.
local BUILD=80
local CANDIDATES={"main.lua","Workspace/main.lua","Delta/Workspace/main.lua"}
local source
for _,path in ipairs(CANDIDATES)do
 local ok,value=pcall(function()return readfile(path)end)
 if ok and type(value)=="string"and #value>100000 then source=value;print("[DeepSeekUI] main.lua <- "..path);break end
end
assert(source,"DeepSeekUI main.lua was not found in the executor workspace (place it next to demo.lua)")
local loader,compileError=loadstring(source,"DeepSeekUI/main")
assert(loader,compileError)
local WindUI=loader()
local DS=assert(WindUI.DeepSeek,"DeepSeek API is missing")
assert(DS.Build==BUILD,"Expected DeepSeek UI build "..BUILD)

local Window=WindUI:CreateWindow({
 Title="DeepSeek UI / 深度求索",Icon="ds:logo",Author="DeepSeek AI · Build 80",Folder="DeepSeekUI",
 Size=UDim2.fromOffset(720,500),MinSize=Vector2.new(580,380),MaxSize=Vector2.new(940,680),
 Transparent=false,Theme="Dark",HideSearchBar=false,ScrollBarEnabled=false,SideBarWidth=200,
 Acrylic=false,User={Enabled=false,Anonymous=false},
})
local Group="Home / 首页"
local folders=setmetatable({},{__mode="k"})
local errors={}
local function Call(parent,kind,props)
 if not parent then errors[#errors+1]=kind..": nil parent";return nil end
 props=props or{}
 if kind=="Section"then
  if props.Opened==nil then props.Opened=true end
  if props.Box==nil then props.Box=false end
 end
 local target=(kind=="Section"or kind=="Group"or kind=="HStack"or kind=="VStack")and parent or(folders[parent]or parent)
 local fn=target[kind]
 if type(fn)~="function"then errors[#errors+1]=kind..": missing native constructor";warn("[DeepSeekUI demo80] "..errors[#errors]);return nil end
 local ok,result=pcall(fn,target,props)
 if not ok or not result then errors[#errors+1]=kind..": "..tostring(result);warn("[DeepSeekUI demo80] "..errors[#errors]);return nil end
 if kind=="Section"then folders[parent]=result end
 if props.Title and kind~="Section"and DS.RegisterJump then DS.RegisterJump(props.Title,result,Group)end
 return result
end
local function Notify(title,content)WindUI:Notify({Title=title,Content=content,Duration=4})end
local TICKER_ORDER={"Auto Run / 自动运行","Team Check / 队伍检查","ESP Boxes / 方框","Sound / 音频"}
local TICKER_ENABLED={
 ["Auto Run / 自动运行"]=false,
 ["Team Check / 队伍检查"]=true,
 ["ESP Boxes / 方框"]=false,
 ["Sound / 音频"]=true,
}
local function TickerSync()
 local active={}
 for _,name in ipairs(TICKER_ORDER)do if TICKER_ENABLED[name]==true then active[#active+1]=name end end
 DS.Ticker.Set(active)
end
local function Ticker(name,enabled)
 TICKER_ENABLED[name]=enabled==true
 TickerSync()
end
local function Log(label,value)print("[demo80] "..label,value)end

pcall(function()Window:Tag({Title="",Icon="ds:lockup",Height=30,IconWidth=126,IconHeight=21})end)
Window:CreateTopbarButton("Info","info",function()Notify("DeepSeek UI / 深度求索","Native controls · English + 简体中文")end,24,nil,Color3.fromHex("#4D6BFE"))
Window:CreateTopbarButton("Jump","search",function()DS.OpenJump()end,24,nil,Color3.fromHex("#4D6BFE"))
local Home=Window:Tab({Title="Home / 首页",Icon="lucide:house"})
local Controls=Window:Tab({Title="Controls / 控件",Icon="lucide:sliders-horizontal"})
local Scripts=Window:Tab({Title="Scripts / 脚本",Icon="lucide:code"})
local Appearance=Window:Tab({Title="Appearance / 外观",Icon="lucide:palette"})
local About=Window:Tab({Title="About / 关于",Icon="lucide:info"})

Group="Home / 首页"
Call(Home,"Section",{Title="Overview / 概览",Desc="Native window and controls / 原生窗口与控件"})
Call(Home,"Paragraph",{Title="Welcome / 欢迎",Desc="Five ordinary tabs with simple native panels. / 五个普通页签与原生内容面板。"})
Call(Home,"Button",{Title="Notification / 通知",Desc="Show a themed toast / 显示主题提示",Callback=function()Notify("Welcome / 欢迎","Build 80 is ready. / Build 80 已就绪。")end})
Call(Home,"Button",{Title="Dialog / 对话框",Desc="Open a native confirmation / 打开原生确认框",Callback=function()Window:Dialog({Title="Confirm / 确认",Content="Continue with the selected action? / 继续执行所选操作？",Buttons={{Title="Cancel / 取消",Variant="Secondary",Callback=function()end},{Title="Continue / 继续",Variant="Primary",Callback=function()Notify("Done / 完成","Action confirmed / 操作已确认")end}}})end})
Call(Home,"Toggle",{Title="Auto Run / 自动运行",Desc="Adds a row to the live ticker / 在走马灯中添加状态",Value=false,Callback=function(v)Ticker("Auto Run / 自动运行",v)end})
Call(Home,"Slider",{Title="Walk Speed / 移动速度",Desc="Integer step / 整数步进",Step=1,Value={Min=16,Max=300,Default=32},Callback=function(v)Log("speed",v)end})
Call(Home,"Dropdown",{Title="Target Mode / 目标模式",Values={"Nearest / 最近","Lowest health / 最低生命","Highest health / 最高生命"},Value="Nearest / 最近",Callback=function(v)Log("target",v)end})

Group="Controls / 控件"
Call(Controls,"Section",{Title="Switches / 开关"})
Call(Controls,"Toggle",{Title="ESP Boxes / 方框",Value=false,Callback=function(v)Ticker("ESP Boxes / 方框",v)end})
Call(Controls,"Toggle",{Title="Team Check / 队伍检查",Value=true,Callback=function(v)Ticker("Team Check / 队伍检查",v)end})
Call(Controls,"Toggle",{Title="Locked / 锁定项",Value=false,Locked=true})
Call(Controls,"Section",{Title="Sliders / 滑块"})
Call(Controls,"Slider",{Title="Decimal / 小数",Desc="Step 0.25 / 步进 0.25",Step=0.25,IsTooltip=true,Value={Min=-2,Max=2,Default=0.5},Callback=function(v)Log("decimal",v)end})
Call(Controls,"Slider",{Title="Brightness / 亮度",Step=0.01,IsTextbox=false,Value={Min=0,Max=1,Default=0.72},Callback=function(v)Log("brightness",v)end})
Call(Controls,"Slider",{Title="Locked range / 锁定范围",Value={Min=0,Max=100,Default=40},Locked=true})
Call(Controls,"Section",{Title="Choices / 选择"})
Call(Controls,"Dropdown",{Title="Feature set / 功能集合",Values={"ESP","Fly","Speed","Teleport","视觉","移动"},Value={"ESP","Speed"},Multi=true,AllowNone=true,SearchBarEnabled=true,Callback=function(v)Log("features",table.concat(v,", "))end})
Call(Controls,"Dropdown",{Title="Long list / 长列表",Values={"One / 一","Two / 二","Three / 三","Four / 四","Five / 五","Six / 六","Seven / 七","Eight / 八","Nine / 九","Ten / 十","Eleven / 十一","Twelve / 十二"},Value="Three / 三",SearchBarEnabled=true,Callback=function(v)Log("long-list",v)end})
Call(Controls,"Input",{Title="Player / 玩家",Placeholder="Name / 名称",Value="",Callback=function(v)Log("player",v)end})
Call(Controls,"Input",{Title="Notes / 多行备注",Type="Textarea",Placeholder="Write here / 在此输入",Value="第一行：中文\nSecond line: English",Callback=function(v)Log("notes",v)end})
Call(Controls,"Keybind",{Title="Menu key / 菜单键",Value="K",Callback=function(v)Log("key",v)end})
Call(Controls,"Keybind",{Title="Panic key / 紧急键",Value="RightShift",CanChange=false,Callback=function(v)Log("panic",v)end})
Call(Controls,"Colorpicker",{Title="Accent / 强调色",Default=Color3.fromHex("#4D6BFE"),Callback=function(c)DS.SetPalette(c)end})
Call(Controls,"Colorpicker",{Title="Overlay tint / 叠层颜色",Default=Color3.fromRGB(55,190,170),Transparency=0.35,Callback=function(c,a)Log("tint",tostring(c).." / "..tostring(a))end})

Group="Scripts / 脚本"
Call(Scripts,"Section",{Title="Loaders / 加载器"})
for _,item in ipairs({{"Infinite Yield","Admin / 管理"},{"ESP Suite","Visuals / 视觉"},{"Auto Farm","Farm / 自动化"},{"Teleport Hub","Movement / 移动"}})do
 Call(Scripts,"Button",{Title=item[1],Desc=item[2],Callback=function()Notify(item[1],"Example action / 示例操作")end})
end
Call(Scripts,"Paragraph",{Title="Demo actions / 示例操作",Desc="Buttons demonstrate callbacks and do not alter game state. / 按钮仅展示回调，不修改游戏状态。"})
Call(Scripts,"Code",{Title="Lua callback / Lua回调",Code="local enabled = true\nprint('enabled:', enabled)",Height=UDim.new(0,126),CodeSize=13,CanCopied=true,OnCopy=function()Notify("Copied / 已复制","Code copied / 代码已复制")end})
Call(Scripts,"Code",{Title="Configuration / 配置",Code="return {\n    language = '简体中文',\n    enabled = true,\n}",Height=UDim.new(0,112),CodeSize=13,CanCopied=false})

Group="Appearance / 外观"
Call(Appearance,"Section",{Title="Themes / 主题"})
Call(Appearance,"Button",{Title="Dark / 深色",Callback=function()WindUI:SetTheme("Dark")end})
Call(Appearance,"Button",{Title="Light / 浅色",Callback=function()WindUI:SetTheme("Light")end})
Call(Appearance,"Colorpicker",{Title="Theme accent / 主题强调色",Default=Color3.fromHex("#4D6BFE"),Callback=function(c)DS.SetPalette(c)end})
Call(Appearance,"Section",{Title="Typography / 字体"})
local picker=Call(Appearance,"Dropdown",{Title="Font family / 字体家族",Values=DS.Fonts(),Value="Gotham",SearchBarEnabled=true,MenuWidth=220,Callback=function(v)if type(v)=="table"then v=v.Title or v[1]end;local ok,err=DS.SetFont(v);if not ok then Notify("Font error / 字体错误",tostring(err))end end})
local fontUrl=""
Call(Appearance,"Input",{Title="Font URL / 字体网址",Placeholder="https://...",Value="",Callback=function(v)fontUrl=tostring(v or"")end})
Call(Appearance,"Button",{Title="Load web font / 加载网络字体",Callback=function()if fontUrl==""then Notify("Font URL / 字体网址","Enter a URL / 请先输入网址");return end;task.spawn(function()local ok,a,n,c=pcall(DS.LoadFontUrl,fontUrl,"External CJK / 外部中英文字体");if ok and a then if picker and picker.Refresh then picker:Refresh(DS.Fonts())end;Notify("Font loaded / 字体已加载",tostring(n).." · "..tostring(c))else Notify("Font error / 字体错误",tostring(ok and n or a))end end)end})
Call(Appearance,"Slider",{Title="Font scale / 字号比例",Value={Min=70,Max=150,Default=100},Step=1,Callback=function(v)DS.SetFontScale(v/100)end})
Call(Appearance,"Section",{Title="Desk pets / 桌宠贴纸"})
for _,item in ipairs({{"pet","Edge pet / 侧边桌宠"},{"sitter","Top sitter / 顶部桌宠"},{"sticker","Sticker / 贴纸"},{"sound","Welcome sound / 欢迎音频"}})do
 local key,title=item[1],item[2]
 Call(Appearance,"Toggle",{Title=title,Value=true,Callback=function(v)
  DS.SetPart(key,v)
  if key=="sound"then Ticker("Sound / 音频",v)end
 end})
end
Call(Appearance,"Button",{Title="Replay welcome / 重播欢迎音",Callback=function()DS.PlaySound(0.6)end})

Group="About / 关于"
Call(About,"Section",{Title="Build / 构建"})
Call(About,"Paragraph",{Title="DeepSeek UI / 深度求索界面",Desc="WindUI 1.6.65 · Build 80 · English + 简体中文 / 英文 + 简体中文"})
Call(About,"Button",{Title="Feature index / 功能索引",Callback=function()DS.OpenJump()end})
Call(About,"Toggle",{Title="Debug / 调试",Value=false,Callback=function(v)WindUI.Debug=v end})
Call(About,"Button",{Title="Stop welcome sound / 停止欢迎音",Callback=function()DS.StopSound()end})

assert(#errors==0,"[DeepSeekUI demo80] control creation errors:\n"..table.concat(errors,"\n"))
print("[DeepSeekUI demo80] build80 ready: five native tabs")
Window:OnOpen(function()print("[DeepSeekUI] opened")end)
Window:OnClose(function()print("[DeepSeekUI] closed")end)
Window:SelectTab(Home)
task.delay(0.6,function()
 TickerSync()
 Notify("DeepSeek UI / 深度求索界面","Workspace ready / 工作区已就绪")
end)
