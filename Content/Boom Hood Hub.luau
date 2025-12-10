loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaSecurity/Matcha-Scripts/refs/heads/main/Implementations/Ui%20Library.lua"))()

repeat task.wait() until UILib ~= nil

local function getGameName()
	return _G.GameName
end

local ArcaneHub = UILib.new('Arcane Hub', Vector2.new(750, 550), {getGameName})
local autofarmTab = ArcaneHub:Tab('AutoFarm')
local settingsSection = ArcaneHub:Section(autofarmTab, 'Settings')

local plr = game.Players.LocalPlayer
local run = false
local CandyFolder

ArcaneHub:Checkbox(autofarmTab, settingsSection, 'Candy Autofarm Enabled', false, function(state)
	run = state
end)

ArcaneHub:Keybind(autofarmTab, settingsSection, 'Stop Autofarm', 'v', function()
	run = false
end, 'Stop')

ArcaneHub:CreateSettingsTab()

-- Manages candy collection by teleporting to each candy
task.spawn(function()
	while true do
		if run then
			if not CandyFolder then
				for _, v in pairs(game.Workspace:GetChildren()) do
					if string.match(v.Name, "[0-9a-f]+%-%x+%-%x+%-%x+%-%x+") then
						CandyFolder = v
						break
					end
				end
			end

			if not CandyFolder then
				task.wait(3)
				continue
			end

			for _, v in pairs(CandyFolder:GetChildren()) do
				if not run then break end
				if v.ClassName ~= "Script" then
					local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						hrp.Position = v.Position
						task.wait(0.2)
					end
				end
			end
		end
		task.wait(2)
	end
end)

local running = true
while running do
	ArcaneHub:Step()
	task.wait(0.0015)
end
ArcaneHub:Destroy()
