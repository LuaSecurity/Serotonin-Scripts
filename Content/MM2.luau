loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaSecurity/Matcha-Scripts/refs/heads/main/Implementations/Ui%20Library.lua"))()

repeat task.wait() until UILib

local function getGameName() return _G.GameName or "Murder Mystery 2" end
local ArcaneHub = UILib.new('Arcane Hub', Vector2.new(750, 550), {getGameName})
local mm2Tab = ArcaneHub:Tab('Murder Mystery 2')

local espSection = ArcaneHub:Section(mm2Tab, 'ESP')
local gunSection = ArcaneHub:Section(mm2Tab, 'Gun Options')
local coinSection = ArcaneHub:Section(mm2Tab, 'Coin Auto Farm Soon!')

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local plr = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local murderESP, sheriffESP, innocentESP = false, false, false
local gunESP = false
local autoGetGun = false
local autofarm = false
local farmSpeed = 10
local lastPosition
local activeDrawings = {}
local gunDrawing = nil

local cachedMap = nil
local LOGIC_INTERVAL = 0.5
local logicAccumulator = 0
local TICK_RATE = 0.0015

-- Retrieves the current map from workspace
local function getMap()
	if cachedMap and cachedMap.Parent == Workspace then
		return cachedMap
	end

	cachedMap = nil
	for _, v in ipairs(Workspace:GetChildren()) do
		if v:FindFirstChild("CoinContainer") then
			cachedMap = v
			return cachedMap
		end
	end
	return nil
end

-- Checks if a player is the murderer
local function GetMurder(p)
	local char = p.Character
	if not char then return end
	if p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife") then
		return true
	end
end

-- Checks if a player is the sheriff
local function GetSheriff(p)
	local char = p.Character
	if not char then return end
	if p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") then
		return true
	end
end

-- Finds the gun drop in the map
local function GetGunDrop(map)
	for _, v in ipairs(map:GetChildren()) do
		if v.Name == "GunDrop" then
			return v
		end
	end
end

-- Removes all active ESP drawings
local function removeAllESP()
	for character, dData in pairs(activeDrawings) do
		dData.Drawing.Visible = false
		dData.Drawing:Remove()
	end
	table.clear(activeDrawings)
end

-- Removes gun ESP drawing
local function removeGunESP()
	if gunDrawing then
		pcall(function() gunDrawing.Box:Remove() end)
		pcall(function() gunDrawing.Text:Remove() end)
	end
	gunDrawing = nil
end

-- Creates gun ESP drawing elements
local function createGunESP()
	if gunDrawing then return end
	local box = Drawing.new("Square")
	box.Color = Color3.fromRGB(255, 255, 0)
	box.Filled = false
	box.Thickness = 1.5
	box.Visible = false

	local label = Drawing.new("Text")
	label.Text = "GUN"
	label.Size = Vector2.new(16, 16)
	label.Center = true
	label.Outline = true
	label.Color = Color3.fromRGB(255, 255, 0)
	label.Visible = false

	gunDrawing = {Box = box, Text = label}
end

-- Updates gun ESP position and visibility
local function updateGunESP()
	if not gunESP then
		if gunDrawing then
			gunDrawing.Box.Visible = false
			gunDrawing.Text.Visible = false
		end
		return
	end

	local map = getMap()
	if not map then return end
	local gun = GetGunDrop(map)
	if not gun then
		if gunDrawing then
			gunDrawing.Box.Visible = false
			gunDrawing.Text.Visible = false
		end
		return
	end

	createGunESP()
	local top3D = gun.Position + Vector3.new(0, 1, 0)
	local bottom3D = gun.Position - Vector3.new(0, 1, 0)
	local top2D, topOn = WorldToScreen(top3D)
	local bottom2D, bottomOn = WorldToScreen(bottom3D)

	if not (topOn and bottomOn) then
		gunDrawing.Box.Visible = false
		gunDrawing.Text.Visible = false
		return
	end

	local height = math.abs(bottom2D.Y - top2D.Y)
	local width = height
	gunDrawing.Box.Position = Vector2.new(top2D.X - width / 2, top2D.Y)
	gunDrawing.Box.Size = Vector2.new(width, height)
	gunDrawing.Box.Visible = true

	gunDrawing.Text.Position = Vector2.new(top2D.X, top2D.Y - 18)
	gunDrawing.Text.Visible = true
end

-- Manages ESP for individual players
local function managePlayerESP(character, player)
	local targetColor, isVisible = nil, false

	if murderESP and GetMurder(player) then
		targetColor = Color3.fromRGB(255, 0, 0)
		isVisible = true
	elseif sheriffESP and GetSheriff(player) then
		targetColor = Color3.fromRGB(0, 0, 255)
		isVisible = true
	elseif innocentESP and not GetMurder(player) and not GetSheriff(player) then
		targetColor = Color3.fromRGB(0, 255, 0)
		isVisible = true
	end

	local drawingData = activeDrawings[character]

	if isVisible then
		if not drawingData then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			local text = Drawing.new("Text")
			text.Text = character.Name
			text.Outline = true
			text.Center = true
			text.Size = Vector2.new(16, 16)
			text.Color = targetColor
			text.Visible = true

			activeDrawings[character] = {Drawing = text, TargetPart = hrp}
		elseif drawingData.Drawing.Color ~= targetColor then
			drawingData.Drawing.Color = targetColor
			drawingData.Drawing.Visible = true
		end
	elseif drawingData then
		drawingData.Drawing.Visible = false
	end
end

ArcaneHub:Checkbox(mm2Tab, espSection, 'Murder ESP', false, function(state)
	murderESP = state
	if not (murderESP or sheriffESP or innocentESP) then
		removeAllESP()
	end
end)

ArcaneHub:Checkbox(mm2Tab, espSection, 'Sheriff ESP', false, function(state)
	sheriffESP = state
	if not (murderESP or sheriffESP or innocentESP) then
		removeAllESP()
	end
end)

ArcaneHub:Checkbox(mm2Tab, espSection, 'Innocent ESP', false, function(state)
	innocentESP = state
	if not (murderESP or sheriffESP or innocentESP) then
		removeAllESP()
	end
end)

ArcaneHub:Checkbox(mm2Tab, espSection, 'Gun ESP', false, function(state)
	gunESP = state
	if not state then removeGunESP() end
end)

ArcaneHub:Checkbox(mm2Tab, gunSection, 'Auto Get Gun', false, function(state)
	autoGetGun = state
end)

ArcaneHub:Button(mm2Tab, gunSection, 'Get Gun', function()
	local map = getMap()
	local gun = map and GetGunDrop(map)
	local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if gun and hrp then
		lastPosition = hrp.Position
		hrp.Position = gun.Position
		task.wait(0.3)
		hrp.Position = lastPosition
	end
end)

ArcaneHub:CreateSettingsTab()

local playersToRemove = {}
local active = activeDrawings

local running = true
while running do
	task.wait(TICK_RATE)
	logicAccumulator = logicAccumulator + TICK_RATE

	ArcaneHub:Step()

	if (murderESP or sheriffESP or innocentESP) then
		for character, data in pairs(active) do
			local drawing = data.Drawing
			local hrp = data.TargetPart

			if hrp and hrp.Parent then
				if drawing.Visible then
					local screenPos, onScreen = WorldToScreen(hrp.Position)

					drawing.Visible = onScreen
					if onScreen then
						drawing.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
					end
				end
			else
				if drawing then
					drawing:Remove()
					active[character] = nil
				end
			end
		end
	end

	updateGunESP()

	if logicAccumulator >= LOGIC_INTERVAL then
		logicAccumulator = 0

		if (murderESP or sheriffESP or innocentESP) then
			table.clear(playersToRemove)

			for character, dData in pairs(active) do
				local player = Players:FindFirstChild(character.Name)

				if not player or not character:FindFirstChild("HumanoidRootPart") then
					playersToRemove[character] = true
				else
					managePlayerESP(character, player)
				end
			end

			for character, _ in pairs(playersToRemove) do
				local dData = active[character]
				if dData then
					dData.Drawing:Remove()
					active[character] = nil
				end
			end

			for _, player in ipairs(Players:GetChildren()) do
				local character = player.Character
				if player ~= plr and character and character:FindFirstChild("HumanoidRootPart") then
					if not active[character] then
						managePlayerESP(character, player)
					end
				end
			end
		end

		if autoGetGun then
			local map = getMap()
			local gun = map and GetGunDrop(map)
			local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			if gun and hrp then
				lastPosition = hrp.Position
				hrp.Position = gun.Position
				task.wait(0.3)
				hrp.Position = lastPosition
			end
		end
	end
end
