loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaSecurity/Matcha-Scripts/refs/heads/main/Implementations/Ui%20Library.lua"))()

repeat task.wait() until UILib ~= nil

local plr = game.Players.LocalPlayer
local WorldsOrbs = game.Workspace.Map.Stages.Boosts

local function getGameName()
	return _G.GameName
end

local ArcaneHub = UILib.new('Arcane Hub', Vector2.new(750, 550), {getGameName})
local farmTab = ArcaneHub:Tab('Auto Farm')
local autoFarmSection = ArcaneHub:Section(farmTab, 'Auto Farm Control')

local AutoFarmEnabled = false
local OrbsPerSecond = 50
local CurrentWorld = nil
local CurrentWrld = nil
local farmAccumulator = 0

-- Updates the current world based on player's leaderstats
local function UpdateWorld()
	if plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("WORLD") then
		local worldName = plr.leaderstats.WORLD.Value
		local wrld = WorldsOrbs:FindFirstChild(worldName)
		if wrld then
			CurrentWorld = worldName
			CurrentWrld = wrld
		end
	end
end

-- Retrieves stage parts for the current world
local function GetStageParts(wrld, worldName)
	local stages = {}
	for _, v in pairs(wrld:GetChildren()) do
		local stageNumber = tonumber(v.Name:match("MAP_" .. worldName .. "_(%d+)"))
		if stageNumber then
			stages[stageNumber] = v
		end
	end
	return stages
end

ArcaneHub:Checkbox(farmTab, autoFarmSection, 'Enable Auto Farm', false, function(state)
	AutoFarmEnabled = state
end)

ArcaneHub:Slider(farmTab, autoFarmSection, 'Orbs per Second', OrbsPerSecond, function(value)
	OrbsPerSecond = math.clamp(value, 1, 200)
end, 1, 50, 1, ' orbs/s')

ArcaneHub:CreateSettingsTab()

local running = true
while running do
	local dt = 0.0015
	task.wait(dt)
	farmAccumulator = farmAccumulator + dt

	if farmAccumulator >= (AutoFarmEnabled and 1 / OrbsPerSecond or 0.35) then
		farmAccumulator = 0
		pcall(UpdateWorld)
		if AutoFarmEnabled and CurrentWrld and CurrentWorld and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			pcall(function()
				local stages = GetStageParts(CurrentWrld, CurrentWorld)
				if next(stages) then
					local highest = math.max(table.unpack((function()
						local t = {}
						for k in pairs(stages) do table.insert(t, k) end
						return t
					end)()))
					local part = stages[highest]:FindFirstChild("0") or stages[highest]:FindFirstChildWhichIsA("BasePart")
					if part then
						plr.Character.HumanoidRootPart.Position = part.Position
					end
				end
			end)
		end
	end

	ArcaneHub:Step()
end
ArcaneHub:Destroy()
