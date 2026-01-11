-- [[ KOPI'S HUB - AIMBOT UPDATE (PART 1) ]]
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
	-- Visuals
	Box = true,
	Tracers = true,
	Skeleton = false,
	Chams = false,
	Names = true,
	Distance = true,
	HealthBar = true,
	HideTeam = false,
	-- Hitbox
	Hitbox = false,      
	HitboxSize = 20,
	UniversalColor = true,
	-- Aimbot
	Aimbot = false,
	AimPart = "Head",       -- "Head" or "Torso"
	AimTeamCheck = true,    -- Separate team check
	AimFOV = true,          -- Draw Circle
	AimRadius = 100,        -- Circle Size
	AimSmartDist = false,   -- Priority: Distance vs Crosshair
	AimSmooth = 0.2         -- 1 = Instant, 0.1 = Very Smooth
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
	Purple = Color3.fromRGB(180, 80, 255)
}

-- ================= SOUNDS =================
local SoundManager = {}
local SoundRoot = Instance.new("Folder", SoundService)
SoundRoot.Name = "KopiSounds"
local function CreateSound(id, vol)
	local s = Instance.new("Sound", SoundRoot)
	s.SoundId = id; s.Volume = vol; return s
end
local Sounds = {
	Click = CreateSound("rbxassetid://6895079853", 0.5),
	Open = CreateSound("rbxassetid://241837157", 0.5),
	Toggle = CreateSound("rbxassetid://6895079853", 0.4)
}
function SoundManager.Play(name)
	if Sounds[name] then
		local s = Sounds[name]:Clone()
		s.Parent = SoundRoot
		if name=="Toggle" then s.PlaybackSpeed=1.2 end
		s:Play(); game.Debris:AddItem(s,2)
	end
end

-- ================= UTILS =================
local function CreateTween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

getgenv().KOPI_POS = getgenv().KOPI_POS or {X = 100, Y = 100}
local function SavePosition(pos) getgenv().KOPI_POS = {X = pos.X.Offset, Y = pos.Y.Offset} end
local function LoadPosition() return UDim2.fromOffset(getgenv().KOPI_POS.X, getgenv().KOPI_POS.Y) end

-- ================= UI BUILD =================
if CoreGui:FindFirstChild("KOPI_PREMIUM_UI") then CoreGui.KOPI_PREMIUM_UI:Destroy() end
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "KOPI_PREMIUM_UI"
ScreenGui.ResetOnSpawn = false

-- [[ MAIN FRAME ]]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.fromOffset(340, 380) -- Wider for 4 tabs
MainFrame.Position = LoadPosition()
MainFrame.BackgroundColor3 = THEME.Bg
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
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
local MiniStroke = Instance.new("UIStroke", MiniFrame)
MiniStroke.Color = THEME.Accent; MiniStroke.Thickness = 1.5

local MiniLabel = Instance.new("TextLabel", MiniFrame)
MiniLabel.Size = UDim2.new(1,0,1,0)
MiniLabel.BackgroundTransparency = 1
MiniLabel.Text = "OPEN MENU"
MiniLabel.Font = Enum.Font.GothamBlack
MiniLabel.TextSize = 13
MiniLabel.TextColor3 = THEME.Accent

-- [[ DRAGGING ]]
local dragging, dragInput, dragStart, startPos, activeFrame
local isMoving = false

local function UpdateDrag(input)
	if not activeFrame then return end
	local delta = input.Position - dragStart
	if delta.Magnitude > 3 then isMoving = true end
	local targetX = startPos.X.Offset + delta.X
	local targetY = startPos.Y.Offset + delta.Y
	local vp = Camera.ViewportSize
	local frameSize = activeFrame.AbsoluteSize
	local clampedX = math.clamp(targetX, 0, vp.X - frameSize.X)
	local clampedY = math.clamp(targetY, 0, vp.Y - frameSize.Y)
	CreateTween(activeFrame, {Position = UDim2.fromOffset(clampedX, clampedY)}, 0.05)
end

local function MakeDraggable(trigger, frameToMove, onClick)
	trigger.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; isMoving = false; dragStart = input.Position; startPos = frameToMove.Position; activeFrame = frameToMove
			local con; con = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false; con:Disconnect(); SavePosition(frameToMove.Position)
					if not isMoving and onClick then onClick() end
				end
			end)
		end
	end)
end

-- [[ HEADER & TABS ]]
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = THEME.Header
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)
local Title = Instance.new("TextLabel", Header)
Title.Text = "KOPI'S <font color=\"rgb(85,120,255)\">HUB</font>"
Title.RichText = true; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 16
Title.TextColor3 = THEME.Text; Title.Position = UDim2.new(0, 14, 0, 0); Title.Size = UDim2.new(1, -50, 1, 0)
Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left

MakeDraggable(Header, MainFrame, nil)
MakeDraggable(MiniFrame, MiniFrame, function()
	SoundManager.Play("Open")
	MainFrame.Position = MiniFrame.Position
	MiniFrame.Visible = false
	MainFrame.Visible = true
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateDrag(input) end
end)

local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Size = UDim2.fromOffset(30, 30)
MinimizeBtn.Position = UDim2.new(1, -38, 0.5, -15)
MinimizeBtn.Text = "—"
MinimizeBtn.Font = Enum.Font.GothamBold; MinimizeBtn.TextSize = 18
MinimizeBtn.TextColor3 = THEME.TextDim; MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)
MinimizeBtn.MouseButton1Click:Connect(function() SoundManager.Play("Click"); MiniFrame.Position = MainFrame.Position; MainFrame.Visible = false; MiniFrame.Visible = true end)

-- [[ TABS SYSTEM ]]
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Position = UDim2.new(0, 10, 0, 50); TabContainer.Size = UDim2.new(1, -20, 0, 34)
TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8)
local TabHighlight = Instance.new("Frame", TabContainer)
TabHighlight.Size = UDim2.new(0.25, -4, 1, -4); TabHighlight.Position = UDim2.new(0, 2, 0, 2)
TabHighlight.BackgroundColor3 = THEME.Accent; Instance.new("UICorner", TabHighlight).CornerRadius = UDim.new(0, 6)

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 10, 0, 94); PageContainer.Size = UDim2.new(1, -20, 1, -104)
PageContainer.BackgroundTransparency = 1; PageContainer.ClipsDescendants = true

-- Pages
local VisPage = Instance.new("ScrollingFrame", PageContainer)
VisPage.Size = UDim2.new(1,0,1,0); VisPage.BackgroundTransparency = 1; VisPage.ScrollBarThickness = 2; VisPage.BorderSizePixel = 0
local VisLayout = Instance.new("UIListLayout", VisPage); VisLayout.Padding = UDim.new(0, 8)

local TargPage = Instance.new("Frame", PageContainer)
TargPage.Size = UDim2.new(1,0,1,0); TargPage.BackgroundTransparency = 1; TargPage.Visible = false

local HitboxPage = Instance.new("Frame", PageContainer)
HitboxPage.Size = UDim2.new(1,0,1,0); HitboxPage.BackgroundTransparency = 1; HitboxPage.Visible = false
local HitboxLayout = Instance.new("UIListLayout", HitboxPage); HitboxLayout.Padding = UDim.new(0, 8)

local AimPage = Instance.new("Frame", PageContainer)
AimPage.Size = UDim2.new(1,0,1,0); AimPage.BackgroundTransparency = 1; AimPage.Visible = false
local AimLayout = Instance.new("UIListLayout", AimPage); AimLayout.Padding = UDim.new(0, 8)

-- Function to switch tabs
local function CreateTabBtn(text, posScale, pageToShow)
	local b = Instance.new("TextButton", TabContainer)
	b.Size = UDim2.new(0.25, 0, 1, 0); b.Position = UDim2.new(posScale, 0, 0, 0)
	b.BackgroundTransparency = 1; b.Text = text; b.Font = Enum.Font.GothamBold
	b.TextSize = 9; b.TextColor3 = THEME.Text; b.ZIndex = 2
	b.MouseButton1Click:Connect(function() 
		SoundManager.Play("Click")
		CreateTween(TabHighlight, {Position = UDim2.new(posScale, 2, 0, 2)})
		VisPage.Visible = false; TargPage.Visible = false; HitboxPage.Visible = false; AimPage.Visible = false
		pageToShow.Visible = true
	end)
end

CreateTabBtn("VISUALS", 0, VisPage)
CreateTabBtn("TARGETS", 0.25, TargPage)
CreateTabBtn("HITBOX", 0.5, HitboxPage)
CreateTabBtn("AIMBOT", 0.75, AimPage)

-- [[ UI COMPONENT FACTORY ]]
local function CreateToggle(parent, text, configKey, callback)
	local Btn = Instance.new("TextButton", parent)
	Btn.Size = UDim2.new(1, 0, 0, 36); Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	Btn.AutoButtonColor = false; Btn.Text = ""; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
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
		ESP_SETTINGS[configKey] = not ESP_SETTINGS[configKey]; SoundManager.Play("Toggle")
		if ESP_SETTINGS[configKey] then CreateTween(Sw, {BackgroundColor3 = THEME.Accent}); CreateTween(Circ, {Position = UDim2.new(1, -18, 0.5, -8)})
		else CreateTween(Sw, {BackgroundColor3 = Color3.fromRGB(50,50,60)}); CreateTween(Circ, {Position = UDim2.new(0, 2, 0.5, -8)}) end
		if callback then callback(ESP_SETTINGS[configKey]) end
	end)
	return Btn 
end

local function CreateButton(parent, text, cb)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1,0,0,32); b.BackgroundColor3 = Color3.fromRGB(40,40,50)
	b.Text = text; b.TextColor3 = THEME.Text; b.Font = Enum.Font.GothamBold; b.TextSize = 12
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
	b.MouseButton1Click:Connect(function() SoundManager.Play("Click"); cb(b) end)
end

-- [[ BUILD VISUALS ]]
CreateToggle(VisPage, "ESP Boxes", "Box")
CreateToggle(VisPage, "Skeleton", "Skeleton")
CreateToggle(VisPage, "Chams", "Chams")
CreateToggle(VisPage, "Tracers", "Tracers")
CreateToggle(VisPage, "Names", "Names")
CreateToggle(VisPage, "Distance", "Distance")
CreateToggle(VisPage, "Health Bar + HP", "HealthBar")
CreateToggle(VisPage, "Hide Team", "HideTeam")
VisLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() VisPage.CanvasSize = UDim2.fromOffset(0, VisLayout.AbsoluteContentSize.Y + 10) end)

-- [[ BUILD TARGETS ]]
local TargInput = Instance.new("TextBox", TargPage)
TargInput.Size = UDim2.new(1, 0, 0, 36); TargInput.BackgroundColor3 = Color3.fromRGB(25,25,30)
TargInput.TextColor3 = Color3.new(1,1,1); TargInput.PlaceholderText = "Add Target..."; TargInput.Font = Enum.Font.Gotham; TargInput.TextSize = 14
Instance.new("UICorner", TargInput).CornerRadius = UDim.new(0,8); Instance.new("UIStroke", TargInput).Color = THEME.Stroke
local ClearBtn = Instance.new("TextButton", TargPage)
ClearBtn.Size = UDim2.new(1, 0, 0, 32); ClearBtn.Position = UDim2.new(0, 0, 1, -32)
ClearBtn.BackgroundColor3 = Color3.fromRGB(40,20,20); ClearBtn.Text = "CLEAR ALL"; ClearBtn.TextColor3 = THEME.Red; ClearBtn.Font = Enum.Font.GothamBold; ClearBtn.TextSize = 13
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", ClearBtn).Color = THEME.Red; Instance.new("UIStroke", ClearBtn).Thickness = 1
local TargScroll = Instance.new("ScrollingFrame", TargPage)
TargScroll.Position = UDim2.fromOffset(0, 42); TargScroll.Size = UDim2.new(1,0,1,-80); TargScroll.BackgroundTransparency = 1; TargScroll.BorderSizePixel = 0
local TLayout = Instance.new("UIListLayout", TargScroll); TLayout.Padding = UDim.new(0, 4)

local function RefreshTargets()
	for _,c in ipairs(TargScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	for i, v in ipairs(RainbowTargets) do
		local f = Instance.new("Frame", TargScroll); f.Size = UDim2.new(1,0,0,30); f.BackgroundColor3 = Color3.fromRGB(35,35,45)
		Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
		local t = Instance.new("TextLabel", f); t.Text = v; t.Size = UDim2.new(1,-30,1,0); t.Position = UDim2.new(0,10,0,0); t.Font = Enum.Font.Gotham; t.TextColor3 = THEME.Text; t.TextXAlignment = Enum.TextXAlignment.Left; t.BackgroundTransparency = 1
		local del = Instance.new("TextButton", f); del.Size = UDim2.fromOffset(24,24); del.Position = UDim2.new(1,-28,0,3); del.Text = "X"; del.BackgroundColor3 = THEME.Red; del.TextColor3 = Color3.new(1,1,1)
		Instance.new("UICorner", del).CornerRadius = UDim.new(0,4); del.MouseButton1Click:Connect(function() table.remove(RainbowTargets, i); SoundManager.Play("Click"); RefreshTargets() end)
	end
end
TargInput.FocusLost:Connect(function(enter)
	if enter and TargInput.Text ~= "" then table.insert(RainbowTargets, TargInput.Text:lower()); TargInput.Text = ""; SoundManager.Play("Open"); RefreshTargets() end
end)
ClearBtn.MouseButton1Click:Connect(function() table.clear(RainbowTargets); SoundManager.Play("Click"); RefreshTargets() end)

-- [[ BUILD HITBOX ]]
local function ResetHitboxLogic()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1; hrp.CanCollide = true; hrp.Color = Color3.new(0.63, 0.63, 0.63)
			end
		end
	end
end

local HitToggleBtn = CreateToggle(HitboxPage, "Enable Hitbox", "Hitbox", function(state) if state == false then ResetHitboxLogic() end end)
CreateToggle(HitboxPage, "Universal Color", "UniversalColor")

local CustomInput = Instance.new("TextBox", HitboxPage)
CustomInput.Size = UDim2.new(1, 0, 0, 36); CustomInput.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
CustomInput.TextColor3 = THEME.Text; CustomInput.PlaceholderText = tostring(ESP_SETTINGS.HitboxSize); CustomInput.Font = Enum.Font.Gotham; CustomInput.TextSize = 14
Instance.new("UICorner", CustomInput).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", CustomInput).Color = THEME.Stroke
CustomInput.FocusLost:Connect(function(enter)
	if enter then
		local num = tonumber(CustomInput.Text)
		if num then ESP_SETTINGS.HitboxSize = num; CustomInput.Text = "Size: " .. num; SoundManager.Play("Open")
		else CustomInput.Text = ""; CustomInput.PlaceholderText = "Invalid Number" end
	end
end)

local PresetsFrame = Instance.new("Frame", HitboxPage)
PresetsFrame.Size = UDim2.new(1, 0, 0, 30); PresetsFrame.BackgroundTransparency = 1
local PresetsLayout = Instance.new("UIListLayout", PresetsFrame); PresetsLayout.FillDirection = Enum.FillDirection.Horizontal; PresetsLayout.Padding = UDim.new(0, 8)
local function CreatePreset(text, sizeVal)
	local b = Instance.new("TextButton", PresetsFrame); b.Size = UDim2.new(0.31, 0, 1, 0); b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	b.Text = text; b.Font = Enum.Font.GothamBold; b.TextColor3 = THEME.Text; b.TextSize = 12
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	b.MouseButton1Click:Connect(function() ESP_SETTINGS.HitboxSize = sizeVal; CustomInput.Text = "Size: " .. sizeVal; SoundManager.Play("Click") end)
end
CreatePreset("Small (10)", 10); CreatePreset("Normal (20)", 20); CreatePreset("Big (50)", 50)

local ResetBtn = Instance.new("TextButton", HitboxPage)
ResetBtn.Size = UDim2.new(1, 0, 0, 32); ResetBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
ResetBtn.Text = "RESET DEFAULT"; ResetBtn.TextColor3 = THEME.Red; ResetBtn.Font = Enum.Font.GothamBold; ResetBtn.TextSize = 13
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", ResetBtn).Color = THEME.Red; Instance.new("UIStroke", ResetBtn).Thickness = 1
ResetBtn.MouseButton1Click:Connect(function()
	SoundManager.Play("Click"); ESP_SETTINGS.Hitbox = false
	local sw = HitToggleBtn:FindFirstChild("Frame"); if sw then CreateTween(sw, {BackgroundColor3 = Color3.fromRGB(50,50,60)}); local c = sw:FindFirstChild("Frame"); if c then CreateTween(c, {Position = UDim2.new(0, 2, 0.5, -8)}) end end
	ResetHitboxLogic()
end)

-- [[ BUILD AIMBOT ]]
CreateToggle(AimPage, "Enable Aimbot", "Aimbot")
CreateToggle(AimPage, "Team Check", "AimTeamCheck")
CreateToggle(AimPage, "Show FOV", "AimFOV")
CreateToggle(AimPage, "Prioritize Distance", "AimSmartDist")

CreateButton(AimPage, "Target Part: Head", function(btn) 
	if ESP_SETTINGS.AimPart == "Head" then ESP_SETTINGS.AimPart = "Torso" else ESP_SETTINGS.AimPart = "Head" end
	btn.Text = "Target Part: " .. ESP_SETTINGS.AimPart
end)

CreateButton(AimPage, "Smoothness: Legit", function(btn)
	-- Cycle: Legit(0.2) -> Fast(0.5) -> Instant(1)
	if ESP_SETTINGS.AimSmooth == 0.2 then
		ESP_SETTINGS.AimSmooth = 0.5; btn.Text = "Smoothness: Fast"
	elseif ESP_SETTINGS.AimSmooth == 0.5 then
		ESP_SETTINGS.AimSmooth = 1; btn.Text = "Smoothness: Instant (Lock)"
	else
		ESP_SETTINGS.AimSmooth = 0.2; btn.Text = "Smoothness: Legit"
	end
end)

local FOVInput = Instance.new("TextBox", AimPage)
FOVInput.Size = UDim2.new(1, 0, 0, 36); FOVInput.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
FOVInput.TextColor3 = THEME.Text; FOVInput.PlaceholderText = "FOV Radius: " .. ESP_SETTINGS.AimRadius; FOVInput.Font = Enum.Font.Gotham; FOVInput.TextSize = 14
Instance.new("UICorner", FOVInput).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", FOVInput).Color = THEME.Stroke
FOVInput.FocusLost:Connect(function(enter)
	if enter then
		local num = tonumber(FOVInput.Text)
		if num then ESP_SETTINGS.AimRadius = num; FOVInput.Text = "FOV Radius: " .. num; SoundManager.Play("Open") end
	end
end)
-- [[ KOPI'S HUB - AIMBOT UPDATE (PART 2) ]]

-- [[ DRAWING OBJECTS ]]
local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 2
FOVring.Color = THEME.Purple
FOVring.Filled = false
FOVring.Radius = ESP_SETTINGS.AimRadius
FOVring.Transparency = 1
FOVring.NumSides = 64

-- [[ HELPERS ]]
local ESPStore = {}

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
end

-- [[ FIXED CHAMS LOGIC ]]
local function ApplyChams(character)
	local old = character:FindFirstChild("KopiHighlight")
	if old then old:Destroy() end
	local h = Instance.new("Highlight", character)
	h.Name = "KopiHighlight"
	h.FillTransparency = 0.6; h.OutlineTransparency = 0.2; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function PlayerSetup(p)
	if p.Character then ApplyChams(p.Character) end
	p.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		ApplyChams(char)
	end)
end

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then PlayerSetup(p) end
end
Players.PlayerAdded:Connect(PlayerSetup)

local function isRainbowTarget(name)
	name = name:lower()
	for _,p in ipairs(RainbowTargets) do if name:sub(1,#p) == p then return true end end
	return false
end

local function GetRainbow() return Color3.fromHSV((tick()*0.5)%1, 0.8, 1) end

-- [[ AIMBOT LOGIC HELPERS ]]
local function GetClosestPlayer()
	local closest = nil
	local minDist = math.huge
	local center = Camera.ViewportSize / 2
	
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			-- Team Check
			if ESP_SETTINGS.AimTeamCheck and p.Team == LocalPlayer.Team then continue end
			
			local part = p.Character:FindFirstChild(ESP_SETTINGS.AimPart)
			local hum = p.Character:FindFirstChild("Humanoid")
			
			if part and hum and hum.Health > 0 then
				local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local distToMouse = (Vector2.new(pos.X, pos.Y) - center).Magnitude
					
					-- Check FOV
					if distToMouse <= ESP_SETTINGS.AimRadius then
						-- DISTANCE SORTING LOGIC
						if ESP_SETTINGS.AimSmartDist then
							-- Sort by physical distance
							local dist3D = (LocalPlayer.Character.Head.Position - part.Position).Magnitude
							if dist3D < minDist then
								minDist = dist3D
								closest = part
							end
						else
							-- Sort by crosshair distance
							if distToMouse < minDist then
								minDist = distToMouse
								closest = part
							end
						end
					end
				end
			end
		end
	end
	return closest
end

-- [[ MAIN LOOP ]]
RunService.RenderStepped:Connect(function()
	local vp = Camera.ViewportSize
	local center = Vector2.new(vp.X/2, vp.Y/2)
	
	-- Update FOV Ring
	FOVring.Radius = ESP_SETTINGS.AimRadius
	FOVring.Position = center
	FOVring.Visible = ESP_SETTINGS.Aimbot and ESP_SETTINGS.AimFOV

	-- Aimbot Execution
	if ESP_SETTINGS.Aimbot then
		local targetPart = GetClosestPlayer()
		if targetPart then
			local lookAt = CFrame.new(Camera.CFrame.Position, targetPart.Position)
			Camera.CFrame = Camera.CFrame:Lerp(lookAt, ESP_SETTINGS.AimSmooth)
		end
	end

	-- ESP Execution
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local hum = p.Character:FindFirstChild("Humanoid")
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			
			if hum and hrp and hum.Health > 0 then
				
				local isTeammate = (p.Team == LocalPlayer.Team)
				
				-- [[ HITBOX EXPANDER ]]
				if ESP_SETTINGS.Hitbox then
					if not (ESP_SETTINGS.HideTeam and isTeammate) then
						pcall(function()
							hrp.Size = Vector3.new(ESP_SETTINGS.HitboxSize, ESP_SETTINGS.HitboxSize, ESP_SETTINGS.HitboxSize)
							hrp.Transparency = 0.7
							hrp.CanCollide = false
							
							if ESP_SETTINGS.UniversalColor then
								hrp.Color = Color3.fromRGB(0, 0, 255)
								hrp.Material = Enum.Material.Neon
							else
								if isRainbowTarget(p.Name) then
									hrp.Color = GetRainbow(); hrp.Material = Enum.Material.Neon
								else
									hrp.Color = p.TeamColor.Color; hrp.Material = Enum.Material.ForceField
								end
							end
						end)
					end
				end

				-- [[ VISUALS ]]
				if ESP_SETTINGS.HideTeam and isTeammate then
					cleanup(p);
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
						Bar = D("Line", {Thickness=2}),
						Head = D("Circle", {Thickness=1.5, NumSides=20, Radius=0, Filled=false}),
						Skeleton = {}
					}
					for i=1, 15 do table.insert(ESPStore[p].Skeleton, D("Line", {Thickness=2, Color=Color3.new(1,1,1)})) end
				end
				
				local esp = ESPStore[p]
				local col = isRainbowTarget(p.Name) and GetRainbow() or p.TeamColor.Color
				local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				
				local cham = p.Character:FindFirstChild("KopiHighlight")
				if not cham then if ESP_SETTINGS.Chams then ApplyChams(p.Character) end
				else cham.Enabled = ESP_SETTINGS.Chams; cham.FillColor = col; cham.OutlineColor = Color3.new(1,1,1) end
				
				if onScreen then
					local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
					local size = math.clamp(2000/pos.Z, 25, 300)
					local w, h = size, size*1.5
					
					esp.BoxOutline.Visible = ESP_SETTINGS.Box; esp.Box.Visible = ESP_SETTINGS.Box
					if ESP_SETTINGS.Box then
						esp.Box.Size = Vector2.new(w, h); esp.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2); esp.Box.Color = col
						esp.BoxOutline.Size = Vector2.new(w, h); esp.BoxOutline.Position = esp.Box.Position
					end
					
					esp.Tracer.Visible = ESP_SETTINGS.Tracers
					if ESP_SETTINGS.Tracers then
						esp.Tracer.From = Vector2.new(center.X, vp.Y); esp.Tracer.To = Vector2.new(pos.X, pos.Y + h/2); esp.Tracer.Color = col
					end
					
					esp.Name.Visible = ESP_SETTINGS.Names
					if ESP_SETTINGS.Names then
						esp.Name.Text = p.Name; esp.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 16); esp.Name.Color = col
					end
					
					esp.Info.Visible = (ESP_SETTINGS.Distance or ESP_SETTINGS.HealthBar)
					if esp.Info.Visible then
						local txt = ""
						if ESP_SETTINGS.Distance then txt = math.floor(dist).."m " end
						if ESP_SETTINGS.HealthBar then txt = txt.."["..math.floor(hum.Health).."]" end
						esp.Info.Text = txt; esp.Info.Position = Vector2.new(pos.X, pos.Y + h/2 + 2); esp.Info.Color = col 
					end
					
					esp.Bar.Visible = ESP_SETTINGS.HealthBar; esp.BarOutline.Visible = ESP_SETTINGS.HealthBar
					if ESP_SETTINGS.HealthBar then
						local hp = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
						local barX = pos.X - w/2 - 6
						local barTop = pos.Y - h/2; local barBot = pos.Y + h/2; local barH = h * hp
						esp.BarOutline.From = Vector2.new(barX, barTop); esp.BarOutline.To = Vector2.new(barX, barBot)
						esp.Bar.Color = Color3.fromHSV(hp * 0.3, 1, 1); esp.Bar.From = Vector2.new(barX, barBot); esp.Bar.To = Vector2.new(barX, barBot - barH)
					end
					
					local doSkel = ESP_SETTINGS.Skeleton
					for _, l in ipairs(esp.Skeleton) do l.Visible = false end
					esp.Head.Visible = false
					
					if doSkel then
						local hObj = p.Character:FindFirstChild("Head")
						if hObj then
							local hp, hon = Camera:WorldToViewportPoint(hObj.Position)
							if hon then
								esp.Head.Visible = true; esp.Head.Position = Vector2.new(hp.X, hp.Y); esp.Head.Radius = math.clamp(400/pos.Z, 4, 15); esp.Head.Color = col
							end
						end
						local links = (hum.RigType == Enum.HumanoidRigType.R15) and R15_LINKS or R6_LINKS
						for i, lnk in ipairs(links) do
							local l = esp.Skeleton[i]
							if l then
								local p1 = p.Character:FindFirstChild(lnk[1]); local p2 = p.Character:FindFirstChild(lnk[2])
								if p1 and p2 then
									local s1, o1 = Camera:WorldToViewportPoint(p1.Position); local s2, o2 = Camera:WorldToViewportPoint(p2.Position)
									if o1 and o2 then
										l.Visible = true; l.From = Vector2.new(s1.X, s1.Y); l.To = Vector2.new(s2.X, s2.Y); l.Color = col
									end
								end
							end
						end
					end
				else
					for _, d in pairs(esp) do
						if typeof(d)=="table" then for _,s in pairs(d) do s.Visible=false end else d.Visible=false end
					end
				end
			else
				cleanup(p)
			end
		end
	end
end)

Players.PlayerRemoving:Connect(cleanup)
if CoreGui:FindFirstChild("KOPI_PREMIUM_UI") then
	local mf = CoreGui.KOPI_PREMIUM_UI:FindFirstChild("Frame")
	if mf then mf.Visible = true end
end
