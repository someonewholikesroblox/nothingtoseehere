local Fatality = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/Fatality/refs/heads/main/src/source.luau"))();

Fatality:Loader({
	Name = "PEPSI",
	Duration = 7
});

local Notification = Fatality:CreateNotifier();

Notification:Notify({
	Title = "PEPSI",
	Content = "Hey! thanks for using this menu! credits to fatality.win for ui lib",
	Icon = "clipboard"
})

local Window = Fatality.new({
	Name = "PEPSI",
	Scale = UDim2.new(0, 750, 0, 500),
	Keybind = "Insert",
	Expire = "never",
});

local Menu = Window:AddMenu({
    Name = "FPS",
    Icon = "skull"
})

local Section = Menu:AddSection({
    Position = 'left', -- left , center , right
    Name = "FPS"
});

Section:AddButton({
	Name = "Aimbot & ESP",
	Callback = function(value)
--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
--[[
    RAINBOW ESP + SKELETON + RED LASER AIMBOT + FOV CIRCLE
    → Using Instance.new() instead of Drawing API
    → All GUI-based rendering
    → Wanna be Hacker XD
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera
local Mouse            = LocalPlayer:GetMouse()

local HoldingLMB = false
local Beam, Att0, Att1 = nil, nil, nil
local FOV_RADIUS = 350

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ==================== RAINBOW FUNCTION ====================
local function getRainbow(t)
	local freq = 1.8
	return Color3.new(
		math.sin(freq * t) * 0.5 + 0.5,
		math.sin(freq * t + 2.1) * 0.5 + 0.5,
		math.sin(freq * t + 4.2) * 0.5 + 0.5
	)
end

-- ==================== GUI HELPERS ====================
local ESPObjects = {}
local SkeletonLines = {}

local function createFrame(props)
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = screenGui
	for k, v in pairs(props or {}) do
		frame[k] = v
	end
	return frame
end

local function createLine(thickness)
	local line = Instance.new("Frame")
	line.BorderSizePixel = 0
	line.BackgroundColor3 = Color3.new(1, 1, 1)
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.Visible = false
	line.Parent = screenGui
	return line
end

local function createESPElements()
	-- Box (4 lines forming a rectangle)
	local box = {
		Top = createLine(),
		Bottom = createLine(),
		Left = createLine(),
		Right = createLine()
	}

	-- Name label
	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.TextColor3 = Color3.new(1, 1, 1)
	name.Font = Enum.Font.Code
	name.TextSize = 15
	name.TextStrokeTransparency = 0.5
	name.Visible = false
	name.Parent = screenGui

	-- Tracer line
	local tracer = createLine()

	-- Health bars
	local healthBG = createLine()
	local healthFG = createLine()

	return {
		Box = box,
		Name = name,
		Tracer = tracer,
		HealthBG = healthBG,
		HealthFG = healthFG
	}
end

-- ==================== FOV CIRCLE ====================
local function createCircle()
	local circle = Instance.new("ImageLabel")
	circle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
	circle.BackgroundTransparency = 1
	circle.Image = "rbxassetid://"
	circle.ImageColor3 = Color3.new(1, 1, 1)
	circle.ImageTransparency = 0
	circle.Visible = true
	circle.Parent = screenGui
	return circle
end

local FOVCircle = createCircle()

-- ==================== SKELETON ====================
local SkeletonConnections = {
	R15 = {
		{"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
		{"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"},
		{"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"},
		{"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
		{"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"}
	},
	R6 = {
		{"Head","Torso"},
		{"Torso","Left Arm"}, {"Torso","Right Arm"},
		{"Torso","Left Leg"}, {"Torso","Right Leg"}
	}
}

local function initSkeleton(plr)
	if SkeletonLines[plr] then return end
	SkeletonLines[plr] = {}
	for i = 1, #SkeletonConnections.R15 do
		SkeletonLines[plr][i] = createLine()
	end
end

local function updateLine(line, from, to, color, thickness)
	local distance = (to - from).Magnitude
	local midpoint = (from + to) / 2

	line.Position = UDim2.new(0, midpoint.X, 0, midpoint.Y)
	line.Size = UDim2.new(0, distance, 0, thickness or 2)
	line.Rotation = math.deg(math.atan2(to.Y - from.Y, to.X - from.X))
	line.BackgroundColor3 = color
	line.Visible = true
end

local function updateSkeleton(plr, rainbow)
	local lines = SkeletonLines[plr]
	if not lines then return end

	local char = plr.Character
	if not char then
		for _, line in pairs(lines) do line.Visible = false end
		return
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then
		for _, line in pairs(lines) do line.Visible = false end
		return
	end

	local conns = (hum.RigType == Enum.HumanoidRigType.R15) and SkeletonConnections.R15 or SkeletonConnections.R6
	for i, conn in ipairs(conns) do
		local line = lines[i]
		local p1 = char:FindFirstChild(conn[1])
		local p2 = char:FindFirstChild(conn[2])
		if p1 and p2 then
			local s1, vis1 = Camera:WorldToViewportPoint(p1.Position)
			local s2, vis2 = Camera:WorldToViewportPoint(p2.Position)
			if vis1 and vis2 then
				updateLine(line, Vector2.new(s1.X, s1.Y), Vector2.new(s2.X, s2.Y), rainbow, 2.3)
			else
				line.Visible = false
			end
		else
			line.Visible = false
		end
	end
end

local function cleanupPlayer(plr)
	if ESPObjects[plr] then
		local data = ESPObjects[plr]
		if data.Box then
			for _, line in pairs(data.Box) do line:Destroy() end
		end
		if data.Name then data.Name:Destroy() end
		if data.Tracer then data.Tracer:Destroy() end
		if data.HealthBG then data.HealthBG:Destroy() end
		if data.HealthFG then data.HealthFG:Destroy() end
		ESPObjects[plr] = nil
	end
	if SkeletonLines[plr] then
		for _, line in pairs(SkeletonLines[plr]) do line:Destroy() end
		SkeletonLines[plr] = nil
	end
end

-- ==================== MAIN LOOP ====================
RunService.RenderStepped:Connect(function()
	local now = tick()
	local rainbow = getRainbow(now)
	local viewportSize = Camera.ViewportSize
	local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
	local mousePos = Vector2.new(Mouse.X, Mouse.Y)

	-- FOV Circle
	FOVCircle.Position = UDim2.new(0, center.X - FOV_RADIUS, 0, center.Y - FOV_RADIUS)
	FOVCircle.ImageColor3 = rainbow

	local closestTarget = nil
	local closestDist = FOV_RADIUS

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer or not plr.Character then continue end

		local char = plr.Character
		local hum = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		local head = char:FindFirstChild("Head")

		if not (hum and root and head and hum.Health > 0) then
			local data = ESPObjects[plr]
			if data then
				for _, line in pairs(data.Box) do line.Visible = false end
				data.Name.Visible = false
				data.Tracer.Visible = false
				data.HealthBG.Visible = false
				data.HealthFG.Visible = false
			end
			updateSkeleton(plr, rainbow)
			continue
		end

		-- HEAD ONSCREEN CHECK
		local headScreen, headVisible = Camera:WorldToViewportPoint(head.Position)
		if not headVisible then
			local data = ESPObjects[plr]
			if data then
				for _, line in pairs(data.Box) do line.Visible = false end
				data.Name.Visible = false
				data.Tracer.Visible = false
				data.HealthBG.Visible = false
				data.HealthFG.Visible = false
			end
			updateSkeleton(plr, rainbow)
			continue
		end

		-- AIMBOT CANDIDATE
		local distToMouse = (Vector2.new(headScreen.X, headScreen.Y) - mousePos).Magnitude
		if distToMouse < closestDist then
			closestDist = distToMouse
			closestTarget = head
		end

		-- INIT ESP
		local data = ESPObjects[plr]
		if not data then
			data = createESPElements()
			ESPObjects[plr] = data
		end

		-- INIT SKELETON
		initSkeleton(plr)

		-- BOUNDING BOX
		local success, cframe, size = pcall(char.GetBoundingBox, char)
		if not (success and cframe and size and size.Magnitude > 2 and size.Magnitude < 50) then
			for _, line in pairs(data.Box) do line.Visible = false end
			data.Name.Visible = false
			data.Tracer.Visible = false
			continue
		end

		-- PROJECT CORNERS
		local points = {}
		local half = size / 2
		for x = -1, 1, 2 do
			for y = -1, 1, 2 do
				for z = -1, 1, 2 do
					local corner = cframe * Vector3.new(half.X * x, half.Y * y, half.Z * z)
					local screenPos, onScreen = Camera:WorldToViewportPoint(corner)
					table.insert(points, Vector2.new(screenPos.X, screenPos.Y))
				end
			end
		end

		-- COMPUTE 2D BOX
		local minX, minY = math.huge, math.huge
		local maxX, maxY = -math.huge, -math.huge
		for _, pt in ipairs(points) do
			minX = math.min(minX, pt.X)
			minY = math.min(minY, pt.Y)
			maxX = math.max(maxX, pt.X)
			maxY = math.max(maxY, pt.Y)
		end

		local boxW = maxX - minX
		local boxH = maxY - minY
		if boxW < 1 or boxH < 1 then continue end

		local slimW = boxW * 0.75
		local slimX = minX + (boxW - slimW) / 2

		local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
		local healthLen = boxH * healthPct

		-- UPDATE BOX (4 lines)
		local thickness = 2.2
		updateLine(data.Box.Top, Vector2.new(slimX, minY), Vector2.new(slimX + slimW, minY), rainbow, thickness)
		updateLine(data.Box.Bottom, Vector2.new(slimX, maxY), Vector2.new(slimX + slimW, maxY), rainbow, thickness)
		updateLine(data.Box.Left, Vector2.new(slimX, minY), Vector2.new(slimX, maxY), rainbow, thickness)
		updateLine(data.Box.Right, Vector2.new(slimX + slimW, minY), Vector2.new(slimX + slimW, maxY), rainbow, thickness)

		-- NAME
		data.Name.Text = plr.Name
		data.Name.Position = UDim2.new(0, slimX + slimW / 2, 0, minY - 22)
		data.Name.TextColor3 = rainbow
		data.Name.Visible = true

		-- TRACER
		updateLine(data.Tracer, center, Vector2.new(slimX + slimW / 2, maxY), rainbow, 1.8)

		-- HEALTH BARS
		updateLine(data.HealthBG, Vector2.new(slimX - 8, minY), Vector2.new(slimX - 8, maxY), Color3.new(0, 0, 0), 5)
		updateLine(data.HealthFG, Vector2.new(slimX - 8, maxY), Vector2.new(slimX - 8, maxY - healthLen), rainbow, 3)

		-- SKELETON
		updateSkeleton(plr, rainbow)
	end

	-- AIMBOT & BEAM
	if HoldingLMB and closestTarget then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
		if not Beam then
			Beam = Instance.new("Beam")
			Att0 = Instance.new("Attachment", workspace.Terrain)
			Att1 = Instance.new("Attachment", workspace.Terrain)
			Beam.Attachment0 = Att0
			Beam.Attachment1 = Att1
			Beam.Color = ColorSequence.new(Color3.fromRGB(255, 50, 50))
			Beam.Width0 = 0.25
			Beam.Width1 = 0.25
			Beam.FaceCamera = true
			Beam.Transparency = NumberSequence.new(0.25)
			Beam.LightEmission = 1
			Beam.Parent = workspace.Terrain
		end
		Att0.WorldPosition = Camera.CFrame.Position
		Att1.WorldPosition = closestTarget.Position
	else
		if Beam then
			Beam:Destroy()
			Att0:Destroy()
			Att1:Destroy()
			Beam, Att0, Att1 = nil, nil, nil
		end
	end
end)

-- ==================== INPUT ====================
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		HoldingLMB = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		HoldingLMB = false
	end
end)

-- ==================== CLEANUP ====================
Players.PlayerRemoving:Connect(cleanupPlayer)

print("🚀 RAINBOW ESP + SKELETON + LASER AIMBOT + FOV CIRCLE LOADED (Instance.new version)")
	end,
})

Section:AddButton({
	Name = "Speed ",
	Callback = function(value)
loadstring(game:HttpGet("https://pastebin.com/raw/DH4b3T5S"))();
	end,
})

Section:AddButton({
	Name = "Owl Hub",
	Callback = function(value)
loadstring(game:HttpGet("https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt"))();
	end,
})

local Menu = Window:AddMenu({
    Name = "GUI",
    Icon = "laptop-minimal"
})

local Section = Menu:AddSection({
    Position = 'left', -- left , center , right
    Name = "GUI"
});

Section:AddButton({
	Name = "AnonHub 75 Games Supported OP",
	Callback = function(value)
loadstring(game:HttpGet("https://raw.githubusercontent.com/sa435125/AnonHub/refs/heads/main/anonhub.lua"))();
	end,
})
















