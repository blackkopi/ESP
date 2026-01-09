-- [[ KOPI'S ESP - PREMIUM EDITION (PART 1/2) ]]
-- Build: Mobile Pro V2 | UI & Setup

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= CONFIG VARIABLES =================
getgenv().ESP_SETTINGS = {
	Box = true,
	Tracers = true,
	Skeleton = false,
	Chams = false,
	Names = true,
	Distance = true,
	HealthText = true,
	HealthBar = true,
	HideTeam = false
}

-- ================= THEME & ASSETS =================
local THEME = {
	Background = Color3.fromRGB(18, 18, 24),
	Header = Color3.fromRGB(24, 24, 32),
	Accent = Color3.fromRGB(85, 120, 255),
	Text = Color3.fromRGB(240, 240, 245),
	TextDim = Color3.fromRGB(160, 160, 175),
	Stroke = Color3.fromRGB(50, 50, 70),
	Green = Color3.fromRGB(60, 220, 100),
	Red = Color3.fromRGB(255, 80, 80)
}

-- ================= SOUND MANAGER =================
local SoundManager = {}
local SoundRoot = Instance.new("Folder")
SoundRoot.Name = "KopiSounds"
SoundRoot.Parent = SoundService

local function CreateSound(id, vol)
	local s = Instance.new("Sound", SoundRoot)
	s.SoundId = id
	s.Volume = vol
	return s
end

local Sounds = {
	Click = CreateSound("rbxassetid://6895079853", 0.5),
	Hover = CreateSound("rbxassetid://6895079853", 0.1),
	Open = CreateSound("rbxassetid://241837157", 0.5),
	ToggleOn = CreateSound("rbxassetid://6895079853", 0.4),
}

function SoundManager.Play(name)
	if Sounds[name] then
		local s = Sounds[name]:Clone()
		s.Parent = SoundRoot
		if name == "Hover" then s.PlaybackSpeed = 1.5 end
		if name == "ToggleOn" then s.PlaybackSpeed = 1.2 end
		s:Play()
		game.Debris:AddItem(s, 2)
	end
end

-- ================= UTILITIES =================
local function CreateTween(obj, props, time, style, dir)
	style = style or Enum.EasingStyle.Quart
	dir = dir or Enum.EasingDirection.Out
	time = time or 0.2
	local tw = TweenService:Create(obj, TweenInfo.new(time, style, dir), props)
	tw:Play()
	return tw
end

getgenv().KOPI_POS = getgenv().KOPI_POS or {X = 100, Y = 100}
local function SavePosition(pos) getgenv().KOPI_POS = {X = pos.X.Offset, Y = pos.Y.Offset} end
local function LoadPosition() return UDim2.fromOffset(getgenv().KOPI_POS.X, getgenv().KOPI_POS.Y) end

-- ================= UI CONSTRUCTION =================
if CoreGui:FindFirstChild("KOPI_PREMIUM_UI") then CoreGui.KOPI_PREMIUM_UI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KOPI_PREMIUM_UI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.fromOffset(260, 350)
MainFrame.Position = LoadPosition()
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true 

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 16)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = THEME.Stroke
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.5

local Shadow = Instance.new("ImageLabel", MainFrame)
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 80, 1, 80)
Shadow.ZIndex = 0
Shadow.Image = "rbxassetid://6015897843" 
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.4

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = THEME.Header
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel", Header)
Title.Text = "KOPI'S ESP <font color=\"rgb(85,120,255)\">PRO</font>"
Title.RichText = true
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextColor3 = THEME.Text
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local dragging, dragInput, dragStart, startPos
local function UpdateDrag(input)
	local delta = input.Position - dragStart
	local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	CreateTween(MainFrame, {Position = newPos}, 0.05)
end
Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = input.Position; startPos = MainFrame.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false; SavePosition(MainFrame.Position) end end)
	end
end)
Header.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then UpdateDrag(input) end end)

local MiniBtn = Instance.new("TextButton", Header)
MiniBtn.Size = UDim2.fromOffset(30, 30)
MiniBtn.Position = UDim2.new(1, -38, 0.5, -15)
MiniBtn.Text = "-"
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 20
MiniBtn.TextColor3 = THEME.TextDim
MiniBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
MiniBtn.AutoButtonColor = false
Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(0, 8)

MiniBtn.MouseButton1Click:Connect(function()
	SoundManager.Play("Click")
	if MainFrame.Height.Offset > 60 then
		CreateTween(MainFrame, {Size = UDim2.fromOffset(260, 44)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		MiniBtn.Text = "+"
	else
		CreateTween(MainFrame, {Size = UDim2.fromOffset(260, 350)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		MiniBtn.Text = "-"
	end
end)

local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Position = UDim2.new(0, 10, 0, 50)
TabContainer.Size = UDim2.new(1, -20, 0, 34)
TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8)

local TabHighlight = Instance.new("Frame", TabContainer)
TabHighlight.Size = UDim2.new(0.5, -4, 1, -4)
TabHighlight.Position = UDim2.new(0, 2, 0, 2)
TabHighlight.BackgroundColor3 = THEME.Accent
TabHighlight.BorderSizePixel = 0
Instance.new("UICorner", TabHighlight).CornerRadius = UDim.new(0, 6)

local function CreateTabBtn(text, posScale)
	local b = Instance.new("TextButton", TabContainer)
	b.Size = UDim2.new(0.5, 0, 1, 0)
	b.Position = UDim2.new(posScale, 0, 0, 0)
	b.BackgroundTransparency = 1
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.TextColor3 = THEME.Text
	b.ZIndex = 2
	return b
end

local Tab1 = CreateTabBtn("VISUALS", 0)
local Tab2 = CreateTabBtn("TARGETS", 0.5)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Position = UDim2.new(0, 10, 0, 94)
ContentContainer.Size = UDim2.new(1, -20, 1, -104)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ClipsDescendants = true

local VisualsPage = Instance.new("ScrollingFrame", ContentContainer)
VisualsPage.Size = UDim2.new(1,0,1,0)
VisualsPage.BackgroundTransparency = 1
VisualsPage.ScrollBarThickness = 2
VisualsPage.BorderSizePixel = 0
local VisLayout = Instance.new("UIListLayout", VisualsPage)
VisLayout.Padding = UDim.new(0, 8)
VisLayout.SortOrder = Enum.SortOrder.LayoutOrder

local TargetsPage = Instance.new("Frame", ContentContainer)
TargetsPage.Size = UDim2.new(1,0,1,0)
TargetsPage.BackgroundTransparency = 1
TargetsPage.Visible = false

Tab1.MouseButton1Click:Connect(function()
	SoundManager.Play("Click")
	CreateTween(TabHighlight, {Position = UDim2.new(0, 2, 0, 2)})
	TargetsPage.Visible = false
	VisualsPage.Visible = true
	VisualsPage.CanvasPosition = Vector2.new(0,0)
	CreateTween(VisualsPage, {CanvasPosition = Vector2.new(0,0)}, 0.1) 
end)
Tab2.MouseButton1Click:Connect(function()
	SoundManager.Play("Click")
	CreateTween(TabHighlight, {Position = UDim2.new(0.5, 2, 0, 2)})
	VisualsPage.Visible = false
	TargetsPage.Visible = true
end)

local function CreateToggle(text, configKey, parent)
	local Container = Instance.new("TextButton", parent)
	Container.Size = UDim2.new(1, 0, 0, 36)
	Container.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	Container.AutoButtonColor = false
	Container.Text = ""
	Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)
	
	local Label = Instance.new("TextLabel", Container)
	Label.Text = text
	Label.Font = Enum.Font.GothamSemibold
	Label.TextSize = 14
	Label.TextColor3 = THEME.Text
	Label.Size = UDim2.new(0.7, 0, 1, 0)
	Label.Position = UDim2.new(0, 12, 0, 0)
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.BackgroundTransparency = 1
	
	local SwitchBg = Instance.new("Frame", Container)
	SwitchBg.Size = UDim2.fromOffset(40, 20)
	SwitchBg.Position = UDim2.new(1, -50, 0.5, -10)
	SwitchBg.BackgroundColor3 = ESP_SETTINGS[configKey] and THEME.Accent or Color3.fromRGB(50,50,60)
	Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
	
	local Circle = Instance.new("Frame", SwitchBg)
	Circle.Size = UDim2.fromOffset(16, 16)
	Circle.Position = ESP_SETTINGS[configKey] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
	Circle.BackgroundColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
	
	Container.MouseButton1Click:Connect(function()
		ESP_SETTINGS[configKey] = not ESP_SETTINGS[configKey]
		SoundManager.Play("ToggleOn")
		if ESP_SETTINGS[configKey] then
			CreateTween(SwitchBg, {BackgroundColor3 = THEME.Accent})
			CreateTween(Circle, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.25, Enum.EasingStyle.Back)
		else
			CreateTween(SwitchBg, {BackgroundColor3 = Color3.fromRGB(50,50,60)})
			CreateTween(Circle, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.25, Enum.EasingStyle.Back)
		end
	end)
end

CreateToggle("ESP Boxes", "Box", VisualsPage)
CreateToggle("Skeleton (+Head)", "Skeleton", VisualsPage)
CreateToggle("Chams (Highlight)", "Chams", VisualsPage)
CreateToggle("Tracers", "Tracers", VisualsPage)
CreateToggle("Show Names", "Names", VisualsPage)
CreateToggle("Show Distance", "Distance", VisualsPage)
CreateToggle("Health Bar", "HealthBar", VisualsPage)
CreateToggle("Hide Teammates", "HideTeam", VisualsPage)

VisLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	VisualsPage.CanvasSize = UDim2.fromOffset(0, VisLayout.AbsoluteContentSize.Y + 10)
end)

getgenv().RainbowTargets = {}
local function RefreshTargets()
	for _,c in ipairs(TargetScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	for i, v in ipairs(RainbowTargets) do
		local f = Instance.new("Frame", TargetScroll)
		f.Size = UDim2.new(1,0,0,30)
		f.BackgroundColor3 = Color3.fromRGB(35,35,45)
		Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
		local t = Instance.new("TextLabel", f)
		t.Text = v
		t.Size = UDim2.new(1,-30,1,0)
		t.Position = UDim2.new(0,10,0,0)
		t.Font = Enum.Font.Gotham
		t.TextColor3 = THEME.Text
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.BackgroundTransparency = 1
		local del = Instance.new("TextButton", f)
		del.Size = UDim2.fromOffset(24,24)
		del.Position = UDim2.new(1,-28,0,3)
		del.Text = "X"
		del.BackgroundColor3 = THEME.Red
		del.TextColor3 = Color3.new(1,1,1)
		Instance.new("UICorner", del).CornerRadius = UDim.new(0,4)
		del.MouseButton1Click:Connect(function()
			table.remove(RainbowTargets, i)
			SoundManager.Play("Click")
			RefreshTargets()
		end)
	end
end

local TargetInput = Instance.new("TextBox", TargetsPage)
TargetInput.Size = UDim2.new(1, 0, 0, 36)
TargetInput.BackgroundColor3 = Color3.fromRGB(25,25,30)
TargetInput.TextColor3 = Color3.new(1,1,1)
TargetInput.PlaceholderText = "Type Name & Enter..."
TargetInput.Font = Enum.Font.Gotham
TargetInput.TextSize = 14
Instance.new("UICorner", TargetInput).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", TargetInput).Color = THEME.Stroke

getgenv().TargetScroll = Instance.new("ScrollingFrame", TargetsPage)
TargetScroll.Position = UDim2.fromOffset(0, 42)
TargetScroll.Size = UDim2.new(1,0,1,-42)
TargetScroll.BackgroundTransparency = 1
local TLayout = Instance.new("UIListLayout", TargetScroll)
TLayout.Padding = UDim.new(0, 4)

TargetInput.FocusLost:Connect(function(enter)
	if enter and TargetInput.Text ~= "" then
		table.insert(RainbowTargets, TargetInput.Text:lower())
		TargetInput.Text = ""
		SoundManager.Play("Open")
		RefreshTargets()
	end
end)
-- [[ KOPI'S ESP - PREMIUM EDITION (PART 2/2) ]]
-- Build: Mobile Pro V2 | Logic

local ESPStore = {}
local ChamStore = {} 

local R15_LINKS = {
	{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"LowerTorso", "LeftUpperLeg"},
	{"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
	{"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}, {"UpperTorso", "LeftUpperArm"},
	{"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
	{"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}
}
local R6_LINKS = {{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}}

local function D(t,p)
	local d=Drawing.new(t)
	for k,v in pairs(p) do d[k]=v end
	return d
end

local function cleanup(p)
	if ESPStore[p] then
		for _,d in pairs(ESPStore[p]) do
			if typeof(d)=="table" then for _,s in pairs(d) do s:Remove() end else d:Remove() end
		end
		ESPStore[p]=nil
	end
	if ChamStore[p] then ChamStore[p]:Destroy(); ChamStore[p]=nil end
end

local function isRainbowTarget(name)
	name = name:lower()
	for _,p in ipairs(RainbowTargets) do if name:sub(1,#p) == p then return true end end
	return false
end

local function GetRainbow() return Color3.fromHSV((tick()*0.5)%1, 0.8, 1) end

RunService.RenderStepped:Connect(function()
	local vp = Camera.ViewportSize
	local center = Vector2.new(vp.X/2, vp.Y/2)

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local hum = p.Character:FindFirstChild("Humanoid")
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			
			if hum and hrp and hum.Health > 0 then
				if ESP_SETTINGS.HideTeam and p.Team == LocalPlayer.Team then
					cleanup(p); continue
				end
				
				if not ESPStore[p] then
					ESPStore[p] = {
						Box = D("Square", {Thickness=1.5, Filled=false, Transparency=1}),
						BoxOutline = D("Square", {Thickness=3, Filled=false, Transparency=0.5, Color=Color3.new(0,0,0)}),
						Tracer = D("Line", {Thickness=1, Transparency=1}),
						Name = D("Text", {Size=13, Center=true, Outline=true, Font=2}),
						Info = D("Text", {Size=11, Center=true, Outline=true, Font=2}),
						BarOutline = D("Line", {Thickness=4, Color=Color3.new(0,0,0)}),
						Bar = D("Line", {Thickness=2}),
						Head = D("Circle", {Thickness=1.5, NumSides=20, Radius=0, Filled=false}),
						Skeleton = {}
					}
					for i=1, 15 do table.insert(ESPStore[p].Skeleton, D("Line", {Thickness=2, Color=Color3.new(1,1,1)})) end
				end
				
				local esp = ESPStore[p]
				local col = isRainbowTarget(p.Name) and GetRainbow() or p.TeamColor.Color
				local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				
				-- CHAMS
				if ESP_SETTINGS.Chams then
					if not ChamStore[p] or ChamStore[p].Parent ~= p.Character then
						if ChamStore[p] then ChamStore[p]:Destroy() end
						local h = Instance.new("Highlight", p.Character)
						h.FillTransparency = 0.6; h.OutlineTransparency = 0.2
						ChamStore[p] = h
					end
					ChamStore[p].FillColor = col; ChamStore[p].OutlineColor = Color3.new(1,1,1)
				else
					if ChamStore[p] then ChamStore[p]:Destroy(); ChamStore[p]=nil end
				end
				
				if onScreen then
					local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
					local size = math.clamp(2000/pos.Z, 25, 300)
					local w, h = size, size*1.5
					
					-- Box
					esp.BoxOutline.Visible = ESP_SETTINGS.Box
					esp.Box.Visible = ESP_SETTINGS.Box
					if ESP_SETTINGS.Box then
						esp.Box.Size = Vector2.new(w, h)
						esp.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
						esp.Box.Color = col
						esp.BoxOutline.Size = Vector2.new(w, h)
						esp.BoxOutline.Position = esp.Box.Position
					end
					
					-- Tracer
					esp.Tracer.Visible = ESP_SETTINGS.Tracers
					if ESP_SETTINGS.Tracers then
						esp.Tracer.From = Vector2.new(center.X, vp.Y)
						esp.Tracer.To = Vector2.new(pos.X, pos.Y + h/2)
						esp.Tracer.Color = col
					end
					
					-- Text
					esp.Name.Visible = ESP_SETTINGS.Names
					if ESP_SETTINGS.Names then
						esp.Name.Text = p.Name
						esp.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 16)
						esp.Name.Color = col
					end
					
					esp.Info.Visible = (ESP_SETTINGS.Distance or ESP_SETTINGS.HealthText)
					if esp.Info.Visible then
						local txt = ""
						if ESP_SETTINGS.Distance then txt = math.floor(dist).."m " end
						if ESP_SETTINGS.HealthText then txt = txt.."["..math.floor(hum.Health).."]" end
						esp.Info.Text = txt
						esp.Info.Position = Vector2.new(pos.X, pos.Y + h/2 + 2)
						esp.Info.Color = Color3.new(1,1,1)
					end
					
					-- Health Bar
					esp.Bar.Visible = ESP_SETTINGS.HealthBar
					esp.BarOutline.Visible = ESP_SETTINGS.HealthBar
					if ESP_SETTINGS.HealthBar then
						local hp = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
						local barX = pos.X - w/2 - 6
						local barTop = pos.Y - h/2
						local barBot = pos.Y + h/2
						local barH = h * hp
						
						esp.BarOutline.From = Vector2.new(barX, barTop)
						esp.BarOutline.To = Vector2.new(barX, barBot)
						
						esp.Bar.Color = Color3.fromHSV(hp * 0.3, 1, 1)
						esp.Bar.From = Vector2.new(barX, barBot)
						esp.Bar.To = Vector2.new(barX, barBot - barH)
					end
					
					-- Skeletons + Head
					local doSkel = ESP_SETTINGS.Skeleton
					for _, l in ipairs(esp.Skeleton) do l.Visible = false end
					esp.Head.Visible = false
					
					if doSkel then
						-- Head
						local hObj = p.Character:FindFirstChild("Head")
						if hObj then
							local hp, hon = Camera:WorldToViewportPoint(hObj.Position)
							if hon then
								esp.Head.Visible = true
								esp.Head.Position = Vector2.new(hp.X, hp.Y)
								esp.Head.Radius = math.clamp(400/pos.Z, 4, 15)
								esp.Head.Color = col
							end
						end
						
						-- Lines
						local links = (hum.RigType == Enum.HumanoidRigType.R15) and R15_LINKS or R6_LINKS
						for i, lnk in ipairs(links) do
							local l = esp.Skeleton[i]
							if l then
								local p1 = p.Character:FindFirstChild(lnk[1])
								local p2 = p.Character:FindFirstChild(lnk[2])
								if p1 and p2 then
									local s1, o1 = Camera:WorldToViewportPoint(p1.Position)
									local s2, o2 = Camera:WorldToViewportPoint(p2.Position)
									if o1 and o2 then
										l.Visible = true
										l.From = Vector2.new(s1.X, s1.Y)
										l.To = Vector2.new(s2.X, s2.Y)
										l.Color = col
									end
								end
							end
						end
					end
				else
					-- Offscreen
					for _, d in pairs(esp) do
						if typeof(d)=="table" then for _,s in pairs(d) do s.Visible=false end
						else d.Visible=false end
					end
				end
			else
				cleanup(p)
			end
		end
	end
end)

Players.PlayerRemoving:Connect(cleanup)

local gui = CoreGui:FindFirstChild("KOPI_PREMIUM_UI")
if gui then
	local MainFrame = gui:FindFirstChild("Frame")
	if MainFrame then
		MainFrame.Size = UDim2.fromOffset(0, 0)
		MainFrame.Visible = true
		SoundManager.Play("Open")
		TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(260, 350)}):Play()
	end
end
