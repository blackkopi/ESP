-- [[ KOPI'S ESP - WALLCHECK BUILD (PART 1) ]]

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
	HideTeam = false
}
getgenv().RainbowTargets = {}

-- ================= WALL CHECK =================
local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Blacklist
RayParams.IgnoreWater = true

local function IsBehindWall(character, hrp)
	if not hrp then return false end
	RayParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
	local origin = Camera.CFrame.Position
	local direction = (hrp.Position - origin)
	local result = workspace:Raycast(origin, direction, RayParams)
	return result ~= nil
end

-- ================= UI CLEANUP =================
if CoreGui:FindFirstChild("KOPI_PREMIUM_UI") then
	CoreGui.KOPI_PREMIUM_UI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "KOPI_PREMIUM_UI"
ScreenGui.ResetOnSpawn = false

-- ================= ESP STORAGE =================
local ESPStore = {}

local function D(t,p)
	local d = Drawing.new(t)
	for k,v in pairs(p) do d[k] = v end
	return d
end

local function cleanup(p)
	if ESPStore[p] then
		for _,d in pairs(ESPStore[p]) do
			if typeof(d) == "table" then
				for _,x in pairs(d) do x:Remove() end
			else
				d:Remove()
			end
		end
		ESPStore[p] = nil
	end
end

-- ================= CHAMS =================
local function ApplyChams(character)
	local old = character:FindFirstChild("KopiHighlight")
	if old then old:Destroy() end

	local h = Instance.new("Highlight", character)
	h.Name = "KopiHighlight"
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function PlayerSetup(p)
	if p.Character then ApplyChams(p.Character) end
	p.CharacterAdded:Connect(function(c)
		task.wait(0.5)
		ApplyChams(c)
	end)
end

for _,p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then PlayerSetup(p) end
end
Players.PlayerAdded:Connect(PlayerSetup)

local function isRainbowTarget(name)
	name = name:lower()
	for _,v in ipairs(RainbowTargets) do
		if name:sub(1,#v) == v then return true end
	end
	return false
end

local function GetRainbow()
	return Color3.fromHSV((tick()*0.5)%1, 0.8, 1)
end
-- [[ KOPI'S ESP - WALLCHECK BUILD (PART 2) ]]

RunService.RenderStepped:Connect(function()
	local vp = Camera.ViewportSize
	local center = Vector2.new(vp.X/2, vp.Y)

	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local hum = p.Character:FindFirstChild("Humanoid")
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")

			if hum and hrp and hum.Health > 0 then
				if ESP_SETTINGS.HideTeam and p.Team == LocalPlayer.Team then
					cleanup(p)
					continue
				end

				if not ESPStore[p] then
					ESPStore[p] = {
						Box = D("Square",{Thickness=1.5,Filled=false}),
						BoxOutline = D("Square",{Thickness=3,Filled=false,Color=Color3.new()}),
						Tracer = D("Line",{Thickness=1}),
						Name = D("Text",{Size=13,Center=true,Outline=true}),
						Info = D("Text",{Size=11,Center=true,Outline=true}),
						Bar = D("Line",{Thickness=2}),
						BarOutline = D("Line",{Thickness=4,Color=Color3.new()}),
						Skeleton = {}
					}
					for i=1,15 do
						table.insert(ESPStore[p].Skeleton, D("Line",{Thickness=2}))
					end
				end

				local esp = ESPStore[p]
				local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				local behindWall = IsBehindWall(p.Character, hrp)

				local alpha = behindWall and 0.35 or 1
				local col = isRainbowTarget(p.Name) and GetRainbow() or p.TeamColor.Color

				-- CHAMS
				local cham = p.Character:FindFirstChild("KopiHighlight")
				if cham then
					cham.Enabled = ESP_SETTINGS.Chams
					cham.FillColor = col
					cham.OutlineColor = Color3.new(1,1,1)
					cham.FillTransparency = behindWall and 0.8 or 0.45
					cham.OutlineTransparency = behindWall and 0.5 or 0.2
				end

				if onScreen then
					local size = math.clamp(2000/pos.Z,25,300)
					local w,h = size,size*1.5

					-- BOX
					esp.Box.Visible = ESP_SETTINGS.Box
					esp.BoxOutline.Visible = ESP_SETTINGS.Box
					if ESP_SETTINGS.Box then
						esp.Box.Size = Vector2.new(w,h)
						esp.Box.Position = Vector2.new(pos.X-w/2,pos.Y-h/2)
						esp.Box.Color = col
						esp.Box.Transparency = alpha

						esp.BoxOutline.Size = esp.Box.Size
						esp.BoxOutline.Position = esp.Box.Position
						esp.BoxOutline.Transparency = behindWall and 0.25 or 0.5
					end

					-- TRACER
					esp.Tracer.Visible = ESP_SETTINGS.Tracers
					if ESP_SETTINGS.Tracers then
						esp.Tracer.From = center
						esp.Tracer.To = Vector2.new(pos.X,pos.Y+h/2)
						esp.Tracer.Color = col
						esp.Tracer.Transparency = alpha
					end

					-- NAME
					esp.Name.Visible = ESP_SETTINGS.Names
					if ESP_SETTINGS.Names then
						esp.Name.Text = p.Name
						esp.Name.Position = Vector2.new(pos.X,pos.Y-h/2-14)
						esp.Name.Color = col
						esp.Name.Transparency = 1-alpha
					end

					-- INFO
					esp.Info.Visible = ESP_SETTINGS.Distance
					if ESP_SETTINGS.Distance then
						esp.Info.Text = math.floor((Camera.CFrame.Position-hrp.Position).Magnitude).."m"
						esp.Info.Position = Vector2.new(pos.X,pos.Y+h/2+2)
						esp.Info.Color = col
						esp.Info.Transparency = 1-alpha
					end

					-- HEALTH BAR
					esp.Bar.Visible = ESP_SETTINGS.HealthBar
					esp.BarOutline.Visible = ESP_SETTINGS.HealthBar
					if ESP_SETTINGS.HealthBar then
						local hp = hum.Health/hum.MaxHealth
						local bx = pos.X-w/2-6
						esp.BarOutline.From = Vector2.new(bx,pos.Y-h/2)
						esp.BarOutline.To = Vector2.new(bx,pos.Y+h/2)
						esp.BarOutline.Transparency = behindWall and 0.4 or 1

						esp.Bar.From = Vector2.new(bx,pos.Y+h/2)
						esp.Bar.To = Vector2.new(bx,pos.Y+h/2-h*hp)
						esp.Bar.Color = Color3.fromHSV(hp*0.3,1,1)
						esp.Bar.Transparency = alpha
					end

					-- SKELETON
					for _,l in ipairs(esp.Skeleton) do
						l.Visible = ESP_SETTINGS.Skeleton
						l.Color = col
						l.Transparency = alpha
					end
				else
					for _,d in pairs(esp) do
						if typeof(d)=="table" then
							for _,x in pairs(d) do x.Visible=false end
						else
							d.Visible=false
						end
					end
				end
			else
				cleanup(p)
			end
		end
	end
end)

Players.PlayerRemoving:Connect(cleanup)
