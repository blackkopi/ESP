-- [[ KOPI'S ESP - PREMIUM ANIMATIONS UPDATE (PART 1) ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= CONFIG =================
getgenv().ESP_SETTINGS = {
	Box = true,
	Tracers = true,
	Skeleton = false,
	Chams = true,
	Names = true,
	Distance = true,
	HealthBar = true,
	HideTeam = false,
	PulseChams = true -- New: Makes chams breathe
}
getgenv().RainbowTargets = {}

-- ================= THEME =================
local THEME = {
	Bg = Color3.fromRGB(18, 18, 24),
	Header = Color3.fromRGB(24, 24, 32),
	Accent = Color3.fromRGB(85, 120, 255),
	Text = Color3.fromRGB(240, 240, 245),
	TextDim = Color3.fromRGB(160, 160, 175),
	Stroke = Color3.fromRGB(50, 50, 70),
	Red = Color3.fromRGB(255, 80, 80),
	Green = Color3.fromRGB(80, 255, 120),
	Yellow = Color3.fromRGB(255, 200, 80)
}

-- ================= SOUND & ANIMATION ENGINE =================
local SoundManager = {}
local SoundRoot = Instance.new("Folder", SoundService)
SoundRoot.Name = "KopiSounds_Pro"

local function CreateSound(id, vol)
	local s = Instance.new("Sound", SoundRoot)
	s.SoundId = id; s.Volume = vol; return s
end

local Sounds = {
	Click = CreateSound("rbxassetid://6895079853", 0.6),
	Hover = CreateSound("rbxassetid://6895079853", 0.2), -- Quieter click for hover
	Open = CreateSound("rbxassetid://241837157", 0.6),
	ToggleOn = CreateSound("rbxassetid://6895079853", 0.5),
	ToggleOff = CreateSound("rbxassetid://6895079853", 0.4),
}

function SoundManager.Play(name, pitch)
	if Sounds[name] then
		local s = Sounds[name]:Clone()
		s.Parent = SoundRoot
		s.PlaybackSpeed = pitch or 1
		s:Play()
		game.Debris:AddItem(s, 2)
	end
end

local function Tween(obj, props, time, style, dir)
	TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
end

local function AddButtonEffects(btn)
	btn.MouseEnter:Connect(function()
		SoundManager.Play("Hover", 1.5) -- High pitch for hover
		Tween(btn, {BackgroundTransparency = 0.8}, 0.2) -- Lighten slightly
	end)
	btn.MouseLeave:Connect(function()
		Tween(btn, {BackgroundTransparency = 1}, 0.2) -- Reset
	end)
end

-- ================= UI SETUP =================
getgenv().KOPI_POS = getgenv().KOPI_POS or {X = 100, Y = 100}
local function SavePosition(pos) getgenv().KOPI_POS = {X = pos.X.Offset, Y = pos.Y.Offset} end
local function LoadPosition() return UDim2.fromOffset(getgenv().KOPI_POS.X, getgenv().KOPI_POS.Y) end

if CoreGui:FindFirstChild("KOPI_PREMIUM_UI") then CoreGui.KOPI_PREMIUM_UI:Destroy() end
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "KOPI_PREMIUM_UI"
ScreenGui.ResetOnSpawn = false

-- [[ MAIN FRAME ]]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.fromOffset(260, 360)
MainFrame.Position = LoadPosition()
MainFrame.BackgroundColor3 = THEME.Bg
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false -- Hidden for intro
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = THEME.Stroke; UIStroke.Thickness = 1.5; UIStroke.Transparency = 0.5

-- [[ PILL (MINIMIZED) ]]
local MiniFrame = Instance.new("Frame", ScreenGui)
MiniFrame.Size = UDim2.fromOffset(130, 40)
MiniFrame.Position = MainFrame.Position
MiniFrame.BackgroundColor3 = THEME.Header
MiniFrame.Visible = false
MiniFrame.BorderSizePixel = 0
Instance.new("UICorner", MiniFrame).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", MiniFrame).Color = THEME.Accent

local MiniLabel = Instance.new("TextLabel", MiniFrame)
MiniLabel.Size = UDim2.new(1,0,1,0)
MiniLabel.BackgroundTransparency = 1
MiniLabel.Text = "OPEN ESP"
MiniLabel.Font = Enum.Font.GothamBlack
MiniLabel.TextSize = 13
MiniLabel.TextColor3 = THEME.Accent

-- [[ DRAGGING SYSTEM ]]
local dragging, dragInput, dragStart, startPos, activeFrame
local function UpdateDrag(input)
	if not activeFrame then return end
	local delta = input.Position - dragStart
	local newPos = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
	Tween(activeFrame, {Position = newPos}, 0.05)
end

local function MakeDraggable(trigger, frameToMove, onClick)
	trigger.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = frameToMove.Position; activeFrame = frameToMove
			local con
			con = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false; con:Disconnect(); SavePosition(frameToMove.Position)
					if (input.Position - dragStart).Magnitude < 3 and onClick then onClick() end
				end
			end)
		end
	end)
end

-- [[ HEADER ]]
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = THEME.Header
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel", Header)
Title.Text = "KOPI'S ESP <font color=\"rgb(85,120,255)\">PRO</font>"
Title.RichText = true; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 16
Title.TextColor3 = THEME.Text; Title.Position = UDim2.new(0, 14, 0, 0); Title.Size = UDim2.new(1, -50, 1, 0)
Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Logic
local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Size = UDim2.fromOffset(30, 30); MinimizeBtn.Position = UDim2.new(1, -38, 0.5, -15)
MinimizeBtn.Text = "—"; MinimizeBtn.Font = Enum.Font.GothamBold; MinimizeBtn.TextSize = 18
MinimizeBtn.TextColor3 = THEME.TextDim; MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

MinimizeBtn.MouseButton1Click:Connect(function()
	SoundManager.Play("Click", 0.8)
	-- Shrink Animation
	Tween(MainFrame, {Size = UDim2.fromOffset(260, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	task.wait(0.25)
	MiniFrame.Position = MainFrame.Position
	MainFrame.Visible = false
	MiniFrame.Visible = true
	-- Pop Mini in
	MiniFrame.Size = UDim2.fromOffset(0,0)
	Tween(MiniFrame, {Size = UDim2.fromOffset(130, 40)}, 0.3, Enum.EasingStyle.Back)
end)

MakeDraggable(Header, MainFrame)
MakeDraggable(MiniFrame, MiniFrame, function()
	SoundManager.Play("Open")
	MainFrame.Position = MiniFrame.Position
	MiniFrame.Visible = false
	MainFrame.Visible = true
	-- Grow Animation
	MainFrame.Size = UDim2.fromOffset(260, 0)
	Tween(MainFrame, {Size = UDim2.fromOffset(260, 360)}, 0.4, Enum.EasingStyle.Back)
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateDrag(input) end
end)
-- [[ KOPI'S ESP - PREMIUM ANIMATIONS UPDATE (PART 2) ]]
-- Paste this directly under Part 1

-- [[ TABS & PAGES ]]
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Position = UDim2.new(0, 10, 0, 50); TabContainer.Size = UDim2.new(1, -20, 0, 34)
TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8)
local TabHighlight = Instance.new("Frame", TabContainer)
TabHighlight.Size = UDim2.new(0.5, -4, 1, -4); TabHighlight.Position = UDim2.new(0, 2, 0, 2)
TabHighlight.BackgroundColor3 = THEME.Accent; Instance.new("UICorner", TabHighlight).CornerRadius = UDim.new(0, 6)

local VisPage, TargPage -- Forward declare

local function CreateTabBtn(text, posScale, targetPage)
	local b = Instance.new("TextButton", TabContainer)
	b.Size = UDim2.new(0.5, 0, 1, 0); b.Position = UDim2.new(posScale, 0, 0, 0)
	b.BackgroundTransparency = 1; b.Text = text; b.Font = Enum.Font.GothamBold
	b.TextSize = 13; b.TextColor3 = THEME.Text; b.ZIndex = 2
	
	b.MouseButton1Click:Connect(function()
		SoundManager.Play("Click", 1.2)
		Tween(TabHighlight, {Position = UDim2.new(posScale, 2, 0, 2)}, 0.25, Enum.EasingStyle.Exponential)
		VisPage.Visible = (targetPage == VisPage)
		TargPage.Visible = (targetPage == TargPage)
	end)
end

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 10, 0, 94); PageContainer.Size = UDim2.new(1, -20, 1, -104)
PageContainer.BackgroundTransparency = 1; PageContainer.ClipsDescendants = true

VisPage = Instance.new("ScrollingFrame", PageContainer)
VisPage.Size = UDim2.new(1,0,1,0); VisPage.BackgroundTransparency = 1; VisPage.ScrollBarThickness = 2; VisPage.BorderSizePixel = 0
local VisLayout = Instance.new("UIListLayout", VisPage); VisLayout.Padding = UDim.new(0, 8)

TargPage = Instance.new("Frame", PageContainer)
TargPage.Size = UDim2.new(1,0,1,0); TargPage.BackgroundTransparency = 1; TargPage.Visible = false

CreateTabBtn("VISUALS", 0, VisPage)
CreateTabBtn("TARGETS", 0.5, TargPage)

-- [[ TOGGLES ]]
local function CreateToggle(text, configKey)
	local Btn = Instance.new("TextButton", VisPage)
	Btn.Size = UDim2.new(1, 0, 0, 36); Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	Btn.AutoButtonColor = false; Btn.Text = ""; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
	
	-- Hover Logic
	Btn.MouseEnter:Connect(function()
		Tween(Btn, {BackgroundColor3 = Color3.fromRGB(35, 35, 45)})
		SoundManager.Play("Hover", 1.2)
	end)
	Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Color3.fromRGB(28, 28, 36)}) end)

	local Lbl = Instance.new("TextLabel", Btn)
	Lbl.Text = text; Lbl.Font = Enum.Font.GothamSemibold; Lbl.TextSize = 14
	Lbl.TextColor3 = THEME.Text; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0, 12, 0, 0)
	Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.BackgroundTransparency = 1
	
	local Sw = Instance.new("Frame", Btn)
	Sw.Size = UDim2.fromOffset(40, 20); Sw.Position = UDim2.new(1, -50, 0.5, -10)
	Sw.BackgroundColor3 = ESP_SETTINGS[configKey] and THEME.Accent or Color3.fromRGB(50,50,60)
	Instance.new("UICorner", Sw).CornerRadius = UDim.new(1, 0)
	
	local Circ = Instance.new("Frame", Sw)
	Circ.Size = UDim2.fromOffset(16, 16)
	Circ.Position = ESP_SETTINGS[configKey] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
	Circ.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", Circ).CornerRadius = UDim.new(1, 0)
	
	Btn.MouseButton1Click:Connect(function()
		ESP_SETTINGS[configKey] = not ESP_SETTINGS[configKey]
		SoundManager.Play(ESP_SETTINGS[configKey] and "ToggleOn" or "ToggleOff", ESP_SETTINGS[configKey] and 1.1 or 0.9)
		
		if ESP_SETTINGS[configKey] then
			Tween(Sw, {BackgroundColor3 = THEME.Accent}, 0.2)
			Tween(Circ, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.3, Enum.EasingStyle.Back)
		else
			Tween(Sw, {BackgroundColor3 = Color3.fromRGB(50,50,60)}, 0.2)
			Tween(Circ, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.3, Enum.EasingStyle.Back)
		end
	end)
end

CreateToggle("ESP Boxes", "Box"); CreateToggle("Skeleton", "Skeleton")
CreateToggle("Chams", "Chams"); CreateToggle("Tracers", "Tracers")
CreateToggle("Names", "Names"); CreateToggle("Distance", "Distance")
CreateToggle("Health Bar + HP", "HealthBar"); CreateToggle("Pulse Chams", "PulseChams")
CreateToggle("Hide Team", "HideTeam")

VisLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() VisPage.CanvasSize = UDim2.fromOffset(0, VisLayout.AbsoluteContentSize.Y + 10) end)

-- [[ TARGETS PAGE ]]
local TargInput = Instance.new("TextBox", TargPage)
TargInput.Size = UDim2.new(1, 0, 0, 36); TargInput.BackgroundColor3 = Color3.fromRGB(25,25,30)
TargInput.TextColor3 = Color3.new(1,1,1); TargInput.PlaceholderText = "Add Target..."; TargInput.Font = Enum.Font.Gotham; TargInput.TextSize = 14
Instance.new("UICorner", TargInput).CornerRadius = UDim.new(0,8); Instance.new("UIStroke", TargInput).Color = THEME.Stroke
TargInput.Focused:Connect(function() Tween(TargInput, {BackgroundColor3 = Color3.fromRGB(35,35,45)}) end)
TargInput.FocusLost:Connect(function() Tween(TargInput, {BackgroundColor3 = Color3.fromRGB(25,25,30)}) end)

local ClearBtn = Instance.new("TextButton", TargPage)
ClearBtn.Size = UDim2.new(1, 0, 0, 32); ClearBtn.Position = UDim2.new(0, 0, 1, -32)
ClearBtn.BackgroundColor3 = Color3.fromRGB(40,20,20); ClearBtn.Text = "CLEAR ALL"; ClearBtn.TextColor3 = THEME.Red; ClearBtn.Font = Enum.Font.GothamBold; ClearBtn.TextSize = 13
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", ClearBtn).Color = THEME.Red
AddButtonEffects(ClearBtn)

local TargScroll = Instance.new("ScrollingFrame", TargPage)
TargScroll.Position = UDim2.fromOffset(0, 42); TargScroll.Size = UDim2.new(1,0,1,-80)
TargScroll.BackgroundTransparency = 1; TargScroll.BorderSizePixel = 0
local TLayout = Instance.new("UIListLayout", TargScroll); TLayout.Padding = UDim.new(0, 4)

local function RefreshTargets()
	for _,c in ipairs(TargScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	for i, v in ipairs(RainbowTargets) do
		local f = Instance.new("Frame", TargScroll)
		f.Size = UDim2.new(1,0,0,30); f.BackgroundColor3 = Color3.fromRGB(35,35,45)
		Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
		
		-- Pop in animation
		f.BackgroundTransparency = 1; Tween(f, {BackgroundTransparency = 0}, 0.3)
		
		local t = Instance.new("TextLabel", f)
		t.Text = v; t.Size = UDim2.new(1,-30,1,0); t.Position = UDim2.new(0,10,0,0)
		t.Font = Enum.Font.Gotham; t.TextColor3 = THEME.Text; t.TextXAlignment = Enum.TextXAlignment.Left; t.BackgroundTransparency = 1
		
		local del = Instance.new("TextButton", f)
		del.Size = UDim2.fromOffset(24,24); del.Position = UDim2.new(1,-28,0,3); del.Text = "X"
		del.BackgroundColor3 = THEME.Red; del.TextColor3 = Color3.new(1,1,1)
		Instance.new("UICorner", del).CornerRadius = UDim.new(0,4)
		
		del.MouseButton1Click:Connect(function()
			table.remove(RainbowTargets, i); SoundManager.Play("Click"); RefreshTargets()
		end)
	end
end

TargInput.FocusLost:Connect(function(enter)
	if enter and TargInput.Text ~= "" then
		table.insert(RainbowTargets, TargInput.Text:lower())
		TargInput.Text = ""; SoundManager.Play("Open", 1.5); RefreshTargets()
	end
end)
ClearBtn.MouseButton1Click:Connect(function() table.clear(RainbowTargets); SoundManager.Play("Click", 0.8); RefreshTargets() end)

-- ================= ESP VISUALS =================
local ESPStore = {}

local R15_LINKS = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"}}
local R6_LINKS = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

local function D(t,p)
	local d=Drawing.new(t)
	for k,v in pairs(p) do d[k]=v end
	return d
end

local function ApplyChams(character)
	local old = character:FindFirstChild("KopiHighlight")
	if old then old:Destroy() end
	local h = Instance.new("Highlight", character)
	h.Name = "KopiHighlight"
	h.FillTransparency = 0.6; h.OutlineTransparency = 0.2; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function PlayerSetup(p)
	if p.Character then ApplyChams(p.Character) end
	p.CharacterAdded:Connect(function(char) task.wait(0.5); ApplyChams(char) end)
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then PlayerSetup(p) end end
Players.PlayerAdded:Connect(PlayerSetup)

local function GetRainbow() return Color3.fromHSV((tick()*0.5)%1, 0.8, 1) end

-- Intro Animation
MainFrame.Visible = true
MainFrame.Size = UDim2.fromOffset(260, 0)
SoundManager.Play("Open")
Tween(MainFrame, {Size = UDim2.fromOffset(260, 360)}, 0.6, Enum.EasingStyle.Elastic)

RunService.RenderStepped:Connect(function(dt)
	local vp = Camera.ViewportSize
	local center = Vector2.new(vp.X/2, vp.Y/2)
	local pulse = 0.6 + 0.3 * math.sin(tick() * 3) -- Breathing effect

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local hum = p.Character:FindFirstChild("Humanoid")
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			
			if hum and hrp and hum.Health > 0 then
				if ESP_SETTINGS.HideTeam and p.Team == LocalPlayer.Team then
					if ESPStore[p] then 
						for _,d in pairs(ESPStore[p]) do if typeof(d)=="table" then for _,s in pairs(d) do s.Visible=false end else d.Visible=false end end 
					end
					local h = p.Character:FindFirstChild("KopiHighlight")
					if h then h.Enabled = false end
					continue
				end
				
				if not ESPStore[p] then
					ESPStore[p] = {
						Box = D("Square", {Thickness=1.5, Filled=false, Transparency=1}),
						BoxOutline = D("Square", {Thickness=3, Filled=false, Transparency=0.5, Color=Color3.new(0,0,0)}),
						Tracer = D("Line", {Thickness=1, Transparency=1}),
						Name = D("Text", {Size=13, Center=true, Outline=true, Font=2}),
						Info = D("Text", {Size=11, Center=true, Outline=true, Font=2}),
						BarOutline = D("Line", {Thickness=4, Color=Color3.new(0,0,0)}),
						BarLag = D("Line", {Thickness=2, Color=THEME.Yellow}), -- New Lag Bar
						Bar = D("Line", {Thickness=2}),
						Head = D("Circle", {Thickness=1.5, NumSides=20, Radius=0, Filled=false}),
						Skeleton = {},
						LastHealth = hum.Health -- Store for lerp
					}
					for i=1, 15 do table.insert(ESPStore[p].Skeleton, D("Line", {Thickness=2, Color=Color3.new(1,1,1)})) end
				end
				
				local esp = ESPStore[p]
				local col = table.find(RainbowTargets, p.Name:lower()) and GetRainbow() or p.TeamColor.Color
				local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				
				-- Chams
				local cham = p.Character:FindFirstChild("KopiHighlight")
				if not cham then if ESP_SETTINGS.Chams then ApplyChams(p.Character) end
				else
					cham.Enabled = ESP_SETTINGS.Chams
					cham.FillColor = col
					cham.FillTransparency = ESP_SETTINGS.PulseChams and pulse or 0.6
					cham.OutlineColor = Color3.new(1,1,1)
				end
				
				if onScreen then
					local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
					local size = math.clamp(2000/pos.Z, 25, 300)
					local w, h = size, size*1.5
					
					-- Update Box
					esp.BoxOutline.Visible = ESP_SETTINGS.Box
					esp.Box.Visible = ESP_SETTINGS.Box
					if ESP_SETTINGS.Box then
						esp.Box.Size = Vector2.new(w, h)
						esp.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
						esp.Box.Color = col
						esp.BoxOutline.Size = Vector2.new(w, h); esp.BoxOutline.Position = esp.Box.Position
					end
					
					-- Tracer
					esp.Tracer.Visible = ESP_SETTINGS.Tracers
					if ESP_SETTINGS.Tracers then
						esp.Tracer.From = Vector2.new(center.X, vp.Y)
						esp.Tracer.To = Vector2.new(pos.X, pos.Y + h/2)
						esp.Tracer.Color = col
					end
					
					-- Name
					esp.Name.Visible = ESP_SETTINGS.Names
					if ESP_SETTINGS.Names then
						esp.Name.Text = p.Name; esp.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 16); esp.Name.Color = col
					end
					
					-- Info
					esp.Info.Visible = (ESP_SETTINGS.Distance or ESP_SETTINGS.HealthBar)
					if esp.Info.Visible then
						local txt = ""
						if ESP_SETTINGS.Distance then txt = math.floor(dist).."m " end
						if ESP_SETTINGS.HealthBar then txt = txt.."["..math.floor(hum.Health).."]" end
						esp.Info.Text = txt; esp.Info.Position = Vector2.new(pos.X, pos.Y + h/2 + 2); esp.Info.Color = col 
					end
					
					-- Premium Health Bar
					esp.Bar.Visible = ESP_SETTINGS.HealthBar
					esp.BarOutline.Visible = ESP_SETTINGS.HealthBar
					esp.BarLag.Visible = ESP_SETTINGS.HealthBar
					
					if ESP_SETTINGS.HealthBar then
						local hp = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
						-- Lerp logic for lag bar
						esp.LastHealth = esp.LastHealth + (hum.Health - esp.LastHealth) * 0.1
						local lagHp = math.clamp(esp.LastHealth/hum.MaxHealth, 0, 1)
						
						local barX = pos.X - w/2 - 6
						local barTop = pos.Y - h/2
						local barBot = pos.Y + h/2
						local barH = h * hp
						local lagH = h * lagHp
						
						esp.BarOutline.From = Vector2.new(barX, barTop); esp.BarOutline.To = Vector2.new(barX, barBot)
						
						-- Yellow lag bar
						esp.BarLag.From = Vector2.new(barX, barBot); esp.BarLag.To = Vector2.new(barX, barBot - lagH)
						
						-- Green actual health bar
						esp.Bar.Color = Color3.fromHSV(hp * 0.3, 1, 1)
						esp.Bar.From = Vector2.new(barX, barBot); esp.Bar.To = Vector2.new(barX, barBot - barH)
					end
					
					-- Skeleton
					local doSkel = ESP_SETTINGS.Skeleton
					for _, l in ipairs(esp.Skeleton) do l.Visible = false end
					esp.Head.Visible = false
					
					if doSkel then
						local hObj = p.Character:FindFirstChild("Head")
						if hObj then
							local hp, hon = Camera:WorldToViewportPoint(hObj.Position)
							if hon then
								esp.Head.Visible = true; esp.Head.Position = Vector2.new(hp.X, hp.Y)
								esp.Head.Radius = math.clamp(400/pos.Z, 4, 15); esp.Head.Color = col
							end
						end
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
										l.Visible = true; l.From = Vector2.new(s1.X, s1.Y); l.To = Vector2.new(s2.X, s2.Y); l.Color = col
									end
								end
							end
						end
					end
				else
					-- Hide offscreen
					for _, d in pairs(esp) do
						if typeof(d)=="table" then for _,s in pairs(d) do s.Visible=false end
						elseif typeof(d)~="number" then d.Visible=false end
					end
				end
			else
				-- Cleanup
				if ESPStore[p] then
					for _,d in pairs(ESPStore[p]) do
						if typeof(d)=="table" then for _,s in pairs(d) do s:Remove() end elseif typeof(d)~="number" then d:Remove() end
					end
					ESPStore[p]=nil
				end
			end
		end
	end
end)
