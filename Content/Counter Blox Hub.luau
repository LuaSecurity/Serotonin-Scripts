loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaSecurity/Matcha-Scripts/refs/heads/main/Implementations/Ui%20Library.lua"))()

repeat task.wait() until UILib ~= nil

local function getGameName()
	return _G.GameName
end

local ArcaneHub = UILib.new('Arcane Hub', Vector2.new(850, 650), {getGameName})
local weaponsTab = ArcaneHub:Tab('Weapons')

local mainSection = ArcaneHub:Section(weaponsTab, 'Main Control')
local coreStatsSection = ArcaneHub:Section(weaponsTab, 'Core Weapon Stats')
local spreadSection = ArcaneHub:Section(weaponsTab, 'Spread Control')
local ammoSection = ArcaneHub:Section(weaponsTab, 'Ammo & Range')
local equipSection = ArcaneHub:Section(weaponsTab, 'Equip Speed & Range Modifier')
local knifeSection = ArcaneHub:Section(weaponsTab, 'Knife Modifications')
local scoutSection = ArcaneHub:Section(weaponsTab, 'HVH Scout Configuration')
local wallBangSection = ArcaneHub:Section(weaponsTab, 'Wall Bang')

local enableTweaks = false
local reloadEnabled = false
local fireRateEnabled = false
local spreadEnabled = false
local ammoEnabled = false
local storedAmmoEnabled = false
local rangeEnabled = false
local equipEnabled = false
local rangeModifierEnabled = false
local knifeEnabled = false
local scoutEnabled = false
local wallBangEnabled = false

local reloadTimeValue = 1.5
local fireRateValue = -1
local spreadValue = 0
local ammoValue = -1
local storedAmmoValue = 9999
local rangeValue = 999999
local equipTimeValue = 0.1
local rangeModifierValue = 1000000
local knifeSpeedValue = 250

local scoutWalkSpeed = 1500
local scoutScopedSpeed = 1500
local scoutSpreadValue = 0
local scoutAutoEnabled = true

local replicatedStorage = game:FindFirstChildOfClass("ReplicatedStorage")
local weaponsFolder = replicatedStorage:FindFirstChild("Weapons")
local huInfo = replicatedStorage:FindFirstChild("HUInfo")

-- Safely sets a value on a child object if it exists
local function safeSet(parent, name, val)
	local c = parent and parent:FindFirstChild(name)
	if c then c.Value = val end
end

-- Applies modifications to all weapons in the folder
local function applyAllWeapons()
	if not enableTweaks or not weaponsFolder then return end
	for _, weapon in ipairs(weaponsFolder:GetChildren()) do
		if reloadEnabled then safeSet(weapon, "ReloadTime", reloadTimeValue) end
		if fireRateEnabled then safeSet(weapon, "FireRate", fireRateValue) end
		if equipEnabled then safeSet(weapon, "EquipTime", equipTimeValue) end
		if ammoEnabled then safeSet(weapon, "Ammo", ammoValue) end
		if storedAmmoEnabled then safeSet(weapon, "StoredAmmo", storedAmmoValue) end
		if rangeEnabled then safeSet(weapon, "Range", rangeValue) end
		if rangeModifierEnabled then safeSet(weapon, "RangeModifier", rangeModifierValue) end
		if spreadEnabled then
			local spreadFolder = weapon:FindFirstChild("Spread")
			if spreadFolder then
				for _, s in ipairs(spreadFolder:GetChildren()) do
					if s:IsA("NumberValue") then
						s.Value = spreadValue
					end
				end
			end
		end
	end
end

-- Modifies knife walking speed
local function applyKnifeSpeed()
	if not knifeEnabled or not huInfo then return end
	local tKnife = huInfo:FindFirstChild("T Knife")
	if tKnife then
		safeSet(tKnife, "WalkSpeed", knifeSpeedValue)
	end
end

-- Applies specific tweaks for the Scout weapon
local function applyScoutTweaks()
	if not scoutEnabled or not weaponsFolder then return end
	local scout = weaponsFolder:FindFirstChild("Scout")
	if scout then
		safeSet(scout, "Auto", scoutAutoEnabled)
		local spreadFolder = scout:FindFirstChild("Spread")
		if spreadFolder then
			for _, s in ipairs(spreadFolder:GetChildren()) do
				if s:IsA("NumberValue") then
					s.Value = scoutSpreadValue
				end
			end
		end
	end
	if huInfo then
		local scoutFolder = huInfo:FindFirstChild("Scout")
		if scoutFolder then
			safeSet(scoutFolder, "WalkSpeed", scoutWalkSpeed)
			safeSet(scoutFolder, "Scoped", scoutScopedSpeed)
		end
	end
end

-- Enables wall banging by moving map to ignore parts
local function applyWallBang()
	local workspace = game:FindFirstChildOfClass("Workspace")
	local map = workspace:FindFirstChild("Map")
	local ignoreParts = workspace:FindFirstChild("Ray_Ignore")
	if map and ignoreParts then
		if wallBangEnabled then
			map.Parent = ignoreParts
		else
			map.Parent = workspace
		end
	end
end

ArcaneHub:Checkbox(weaponsTab, mainSection, 'Enable Weapon Mods', false, function(state)
	enableTweaks = state
	if state then
		applyAllWeapons()
		applyKnifeSpeed()
		applyScoutTweaks()
		applyWallBang()
	end
end)

ArcaneHub:Checkbox(weaponsTab, coreStatsSection, 'Modify Reload Time', false, function(state)
	reloadEnabled = state
	if enableTweaks then applyAllWeapons() end
end)
ArcaneHub:Slider(weaponsTab, coreStatsSection, 'Reload Time', reloadTimeValue, function(value)
	reloadTimeValue = value
	if enableTweaks and reloadEnabled then applyAllWeapons() end
end, 0.1, 5, 0.1, ' sec')

ArcaneHub:Checkbox(weaponsTab, coreStatsSection, 'Modify Fire Rate', false, function(state)
	fireRateEnabled = state
	if enableTweaks then applyAllWeapons() end
end)
ArcaneHub:Slider(weaponsTab, coreStatsSection, 'Fire Rate', fireRateValue, function(value)
	fireRateValue = value
	if enableTweaks and fireRateEnabled then applyAllWeapons() end
end, -2, 3, 0.1, '')

ArcaneHub:Checkbox(weaponsTab, spreadSection, 'Modify Spread', false, function(state)
	spreadEnabled = state
	if enableTweaks then applyAllWeapons() end
end)
ArcaneHub:Slider(weaponsTab, spreadSection, 'Spread Value', spreadValue, function(value)
	spreadValue = value
	if enableTweaks and spreadEnabled then applyAllWeapons() end
end, 0, 10, 0.1, '')

ArcaneHub:Checkbox(weaponsTab, ammoSection, 'Modify Ammo', false, function(state)
	ammoEnabled = state
	if enableTweaks then applyAllWeapons() end
end)
ArcaneHub:Slider(weaponsTab, ammoSection, 'Ammo Value', ammoValue, function(value)
	ammoValue = value
	if enableTweaks and ammoEnabled then applyAllWeapons() end
end, -1, 1000, 1, '')

ArcaneHub:Checkbox(weaponsTab, ammoSection, 'Modify Stored Ammo', false, function(state)
	storedAmmoEnabled = state
	if enableTweaks then applyAllWeapons() end
end)
ArcaneHub:Slider(weaponsTab, ammoSection, 'Stored Ammo Value', storedAmmoValue, function(value)
	storedAmmoValue = value
	if enableTweaks and storedAmmoEnabled then applyAllWeapons() end
end, 0, 1e6, 10, '')

ArcaneHub:Checkbox(weaponsTab, ammoSection, 'Modify Range', false, function(state)
	rangeEnabled = state
	if enableTweaks then applyAllWeapons() end
end)
ArcaneHub:Slider(weaponsTab, ammoSection, 'Range', rangeValue, function(value)
	rangeValue = value
	if enableTweaks and rangeEnabled then applyAllWeapons() end
end, 100, 1e8, 100, '')

ArcaneHub:Checkbox(weaponsTab, equipSection, 'Modify Equip Time', false, function(state)
	equipEnabled = state
	if enableTweaks then applyAllWeapons() end
end)
ArcaneHub:Slider(weaponsTab, equipSection, 'Equip Time', equipTimeValue, function(value)
	equipTimeValue = value
	if enableTweaks and equipEnabled then applyAllWeapons() end
end, 0.01, 2, 0.01, ' sec')

ArcaneHub:Checkbox(weaponsTab, equipSection, 'Modify Range Modifier', false, function(state)
	rangeModifierEnabled = state
	if enableTweaks then applyAllWeapons() end
end)
ArcaneHub:Slider(weaponsTab, equipSection, 'Range Modifier', rangeModifierValue, function(value)
	rangeModifierValue = value
	if enableTweaks and rangeModifierEnabled then applyAllWeapons() end
end, 1, 1e8, 100, '')

ArcaneHub:Checkbox(weaponsTab, knifeSection, 'Enable Knife WalkSpeed', false, function(state)
	knifeEnabled = state
	if enableTweaks then applyKnifeSpeed() end
end)
ArcaneHub:Slider(weaponsTab, knifeSection, 'Knife WalkSpeed', knifeSpeedValue, function(value)
	knifeSpeedValue = value
	if enableTweaks and knifeEnabled then applyKnifeSpeed() end
end, 16, 1000, 5, '')

ArcaneHub:Checkbox(weaponsTab, scoutSection, 'Enable HVH Scout', false, function(state)
	scoutEnabled = state
	if enableTweaks then applyScoutTweaks() end
end)
ArcaneHub:Slider(weaponsTab, scoutSection, 'Scout Spread', scoutSpreadValue, function(value)
	scoutSpreadValue = value
	if enableTweaks and scoutEnabled then applyScoutTweaks() end
end, 0, 10, 0.1, '')
ArcaneHub:Slider(weaponsTab, scoutSection, 'Scout WalkSpeed', scoutWalkSpeed, function(value)
	scoutWalkSpeed = value
	if enableTweaks and scoutEnabled then applyScoutTweaks() end
end, 16, 2000, 5, '')
ArcaneHub:Slider(weaponsTab, scoutSection, 'Scout Scoped Speed', scoutScopedSpeed, function(value)
	scoutScopedSpeed = value
	if enableTweaks and scoutEnabled then applyScoutTweaks() end
end, 16, 2000, 5, '')
ArcaneHub:Checkbox(weaponsTab, scoutSection, 'Scout Auto Fire', true, function(state)
	scoutAutoEnabled = state
	if enableTweaks and scoutEnabled then applyScoutTweaks() end
end)

ArcaneHub:Checkbox(weaponsTab, wallBangSection, 'Enable Wall Bang', false, function(state)
	wallBangEnabled = state
	applyWallBang()
end)

ArcaneHub:CreateSettingsTab()

local running = true
while running do
	ArcaneHub:Step()
	task.wait(0.0015)
end
ArcaneHub:Destroy()
