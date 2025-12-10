loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaSecurity/Matcha-Scripts/refs/heads/main/Implementations/Ui%20Library.lua"))()

repeat task.wait() until UILib ~= nil

local function getGameName()
	return _G.GameName
end

local ArcaneHub = UILib.new('Arcane Hub', Vector2.new(600, 450), {getGameName})
local mainTab = ArcaneHub:Tab('Main')
local farmSection = ArcaneHub:Section(mainTab, 'Ticket Autofarm')
local miscSection = ArcaneHub:Section(mainTab, 'Misc Settings')

local player = game.Players.LocalPlayer
local autofarmEnabled = false
local skyTeleportEnabled = true
local inSky = false
local skyHeight = 10000
local checkInterval = 0.5

-- Retrieves the player's character, waiting if necessary
local function getCharacter()
	while not player.Character do
		task.wait()
	end
	return player.Character
end

-- Locates the tickets folder in the game workspace
local function getTicketsFolder()
	local gameFolder = game.Workspace:FindFirstChild("Game")
	if gameFolder then
		local effectsFolder = gameFolder:FindFirstChild("Effects")
		if effectsFolder then
			return effectsFolder:FindFirstChild("Tickets")
		end
	end
end

-- Teleports the character to a specified position
local function teleportTo(pos)
	local char = getCharacter()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.Position = pos
	end
end

-- Moves character to sky if enabled and not already there
local function teleportToSky()
	if skyTeleportEnabled and not inSky then
		local char = getCharacter()
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.Position = hrp.Position + Vector3.new(0, skyHeight, 0)
			inSky = true
		end
	end
end

-- Teleports to a specific ticket's position
local function teleportToTicket(ticket)
	local root = ticket:FindFirstChild("HumanoidRootPart")
	if root then
		teleportTo(root.Position)
		inSky = false
	end
end

-- Manages ticket autofarm by checking for tickets and teleporting accordingly
task.spawn(function()
	while true do
		task.wait(checkInterval)
		if not autofarmEnabled then continue end

		local ticketsFolder = getTicketsFolder()
		if not ticketsFolder then
			if skyTeleportEnabled then teleportToSky() end
			continue
		end

		local tickets = ticketsFolder:GetChildren()
		if #tickets == 0 then
			if skyTeleportEnabled then teleportToSky() end
		else
			for _, ticket in ipairs(tickets) do
				if ticket:IsA("Model") then
					teleportToTicket(ticket)
					break
				end
			end
		end
	end
end)

ArcaneHub:Checkbox(mainTab, farmSection, 'Enable Ticket Autofarm', false, function(state)
	autofarmEnabled = state
	inSky = false
end)

ArcaneHub:Checkbox(mainTab, miscSection, 'Teleport To Sky If No Tickets', true, function(state)
	skyTeleportEnabled = state
end)

ArcaneHub:Slider(mainTab, miscSection, 'Sky Height', 10000, function(value)
	skyHeight = value
end, 1000, 20000, 100, ' studs')

ArcaneHub:Slider(mainTab, miscSection, 'Check Interval', 0.5, function(value)
	checkInterval = value
end, 0.1, 2, 0.1, ' sec')

ArcaneHub:CreateSettingsTab()

local running = true
while running do
	ArcaneHub:Step()
	task.wait(0.0015)
end
ArcaneHub:Destroy()
