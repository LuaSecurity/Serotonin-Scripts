loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaSecurity/Matcha-Scripts/refs/heads/main/Implementations/Ui%20Library.lua"))()

repeat task.wait() until UILib ~= nil

local function getGameName()
	return _G.GameName
end

local ArcaneHub = UILib.new('Arcane Hub', Vector2.new(750, 550), {getGameName})
local weaponsTab = ArcaneHub:Tab('Weapons')
local tpsTab = ArcaneHub:Tab('TPS')

local TPS_LOCATIONS = {
    {"Yard", Vector3.new(784.12, 98, 2460.25)},
	{"Nexus", Vector3.new(875.78, 100, 2392.21)},
    {"Cafeteria", Vector3.new(901.37, 99.99, 2299.91)},
    {"Guard Station", Vector3.new(829.99, 99.99, 2295.10)},
	{"Armory", Vector3.new(830.47, 99.98, 2228.66)},
    {"Prison Cells", Vector3.new(917.76, 99.99, 2454.43)},
    {"Roof", Vector3.new(990.18, 118.99, 2324.80)},
    {"Criminal Base", Vector3.new(-936.75, 94.13, 2054.35)},
}

local PRISON_LIFE_GUNS = {
    "M9",
    "Remington 870",
    "AK-47",
    "FAL",
    "M4A1",
}

local modControlSection = ArcaneHub:Section(weaponsTab, 'Weapon Mod Control')
local statsSection = ArcaneHub:Section(weaponsTab, 'Stats & Projectiles')
local gunSpawnSection = ArcaneHub:Section(weaponsTab, 'Get Guns')
local tpsSection = ArcaneHub:Section(tpsTab, 'Teleport Locations')

local enableTweaks = false
local autoFireEnabled = false
local fireRateEnabled = false
local rangeEnabled = false

local fireRateValue = 0.01
local rangeValue = 1000000

_G.PLModLoop = false

local TOUCH_GIVER_CACHE = {}

local function cacheTouchGivers()
    for _, v in pairs(game.Workspace:GetChildren()) do
        if v.Name == "TouchGiver" then
            local toolName = v:GetAttribute("ToolName")
            if toolName and v:FindFirstChild("TouchGiver") then
                TOUCH_GIVER_CACHE[toolName] = v
            end
        end
    end
end

cacheTouchGivers()

local function teleportToPosition(position)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.Position = position
    end
end

-- Spawns a weapon by teleporting to its touch giver
local function spawnWeapon(weaponName)
    local touchGiver = TOUCH_GIVER_CACHE[weaponName]
    if touchGiver then
        local touchPart = touchGiver:FindFirstChild("TouchGiver")
        if touchPart then
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local originalPosition = character.HumanoidRootPart.Position
                teleportToPosition(touchPart.Position)
                repeat task.wait() until player.Backpack:FindFirstChild(weaponName) or (character and character:FindFirstChild(weaponName))
                teleportToPosition(originalPosition)
            end
        end
    end
end


-- Applies weapon modifications in a loop
local function applyModsLoop()
    while _G.PLModLoop do
        if not enableTweaks then
            task.wait(1)
            continue
        end

        local player = game.Players.LocalPlayer
        if not player or not player.Backpack then
            task.wait(1)
            continue
        end

        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name ~= "Handcuffs" and tool.Name ~= "KeyCard" then
                if fireRateEnabled then tool:SetAttribute("FireRate", fireRateValue) end
                if rangeEnabled then tool:SetAttribute("Range", rangeValue) end
                if autoFireEnabled then tool:SetAttribute("AutoFire", true) end
            end
        end
        task.wait(2)
    end
end

ArcaneHub:Checkbox(weaponsTab, modControlSection, 'Enable Weapon Mods', false, function(state)
	enableTweaks = state
    _G.PLModLoop = state
    if state and not _G.PLModLoop_Running then
        _G.PLModLoop_Running = true
        task.spawn(applyModsLoop)
    end
end)

ArcaneHub:Checkbox(weaponsTab, modControlSection, 'Instant Fire Rate', false, function(state)
	fireRateEnabled = state
end)

ArcaneHub:Slider(weaponsTab, modControlSection, 'Fire Rate', 0.01, function(value)
	fireRateValue = value
end, 0.01, 0.5, 0.01, ' sec')

ArcaneHub:Checkbox(weaponsTab, modControlSection, 'Automatic Guns', false, function(state)
	autoFireEnabled = state
end)

ArcaneHub:Checkbox(weaponsTab, statsSection, 'Extended Range', true, function(state)
	rangeEnabled = state
end)

ArcaneHub:Slider(weaponsTab, statsSection, 'Range', 1000000, function(value)
	rangeValue = value
end, 1000, 1000000, 1000, '')

for _, gunName in ipairs(PRISON_LIFE_GUNS) do
    ArcaneHub:Button(weaponsTab, gunSpawnSection, 'Get ' .. gunName, function()
        spawnWeapon(gunName)
    end)
end

for _, location in ipairs(TPS_LOCATIONS) do
    local name = location[1]
    local pos = location[2]
    ArcaneHub:Button(tpsTab, tpsSection, 'Teleport to ' .. name, function()
        teleportToPosition(pos)
    end)
end

ArcaneHub:CreateSettingsTab()

local running = true
while running do
    ArcaneHub:Step()
	task.wait(0.0015)
end
ArcaneHub:Destroy()
