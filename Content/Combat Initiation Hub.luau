loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaSecurity/Matcha-Scripts/refs/heads/main/Implementations/Ui%20Library.lua"))()

repeat task.wait() until UILib ~= nil

local function getGameName()
	return _G.GameName
end

local ArcaneHub = UILib.new('Arcane Hub', Vector2.new(750, 550), {getGameName})

local combatTab = ArcaneHub:Tab('Combat')
local miscTab = ArcaneHub:Tab('Misc')

local ammoSection = ArcaneHub:Section(combatTab, 'Ammo & Range')
local fireSection = ArcaneHub:Section(combatTab, 'Fire & Reload')
local recoilSection = ArcaneHub:Section(combatTab, 'Recoil & Spread')

local characterStatsSection = ArcaneHub:Section(miscTab, 'Character Stats')
local toolCombatSection = ArcaneHub:Section(miscTab, 'Tool Combat Rates')
local toolDamageSection = ArcaneHub:Section(miscTab, 'Tool Damage & Utility')

local overhaulEnabled = false

local infinityAmmoEnabled = false
local currentAmmo = 2147483647
local currentRange = 2147483647
local currentPenetration = 2147483647

local instantFireEnabled = false
local instantReloadEnabled = false
local currentFireRate = 999
local currentReloadTime = 0

local zeroRecoilEnabled = false
local zeroSpreadEnabled = false
local currentRecoil = 0
local currentSpread = 0

local dashRegenTimeValue = 0.1
local cooldownValue = 0.1
local utilityBoostValue = 64
local aggroMultiplierValue = 100
local toolFirerateValue = 0
local toolSwingrateValue = 0
local toolLungeRateValue = 0
local toolLifestealValue = 21
local toolWindupValue = 0
local toolLungeDamageValue = 155
local toolChargeExplodeDamageValue = 1000
local toolChargeRadiusValue = 31
local toolChargeTimeValue = 0
local toolDetonationPotencyValue = 0
local toolCooldownValue = 0
local toolSpreadValue = 0
local toolMinShotsValue = 30
local toolMaxShotsValue = 30

-- Applies weapon modifications to game objects
local function applyWeaponTweaks()
	task.spawn(function()
		if not (infinityAmmoEnabled or instantFireEnabled or instantReloadEnabled or zeroRecoilEnabled or zeroSpreadEnabled) then return end

		local weaponContainer = game.ReplicatedStorage:FindFirstChild("Import")
		if not weaponContainer or not weaponContainer:FindFirstChild("Guns") or not weaponContainer.Guns:FindFirstChild("Weapons") then return end

		for _, v in pairs(weaponContainer.Guns.Weapons:GetDescendants()) do
			if v:IsA("IntValue") or v:IsA("NumberValue") then
				local name = v.Name

				if infinityAmmoEnabled and (name == "Ammo" or name == "StoredAmmo") then
					v.Value = currentAmmo
				end
				if name == "Penetration" then
					v.Value = currentPenetration
				end
				if name == "Range" then
					v.Value = currentRange
				end

				if instantFireEnabled and name == "FireRate" then
					v.Value = currentFireRate
				end
				if instantReloadEnabled and name == "ReloadTime" then
					v.Value = currentReloadTime
				end

				if zeroRecoilEnabled and name == "Recoil" then
					v.Value = currentRecoil
					for _, c in pairs(v:GetChildren()) do
						if c:IsA("IntValue") or c:IsA("NumberValue") then
							c.Value = currentRecoil
						end
					end
				end
				if zeroSpreadEnabled and name == "Spread" then
					v.Value = currentSpread
					for _, c in pairs(v:GetChildren()) do
						if c:IsA("IntValue") or c:IsA("NumberValue") then
							c.Value = currentSpread
						end
					end
				end
			end
		end
	end)
end

-- Updates character and tool attributes for overhaul
local function applyOverhaulTweaks()
    local character = game:GetService("Players").LocalPlayer.Character
    if not character then return end

    character:SetAttribute("DashRegenTime", dashRegenTimeValue)
    character:SetAttribute("Cooldown", cooldownValue)
    character:SetAttribute("UtilityBoost", utilityBoostValue)
    character:SetAttribute("AggroMultiplier", aggroMultiplierValue)
    
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        tool:SetAttribute("Firerate", toolFirerateValue)
        tool:SetAttribute("Swingrate", toolSwingrateValue)
        tool:SetAttribute("LungeRate", toolLungeRateValue)
        tool:SetAttribute("Lifesteal", toolLifestealValue)
        tool:SetAttribute("Windup", toolWindupValue)
        tool:SetAttribute("LungeDamage", toolLungeDamageValue)
        tool:SetAttribute("ChargeExplodeDamage", toolChargeExplodeDamageValue)
        tool:SetAttribute("ChargeRadius", toolChargeRadiusValue)
        tool:SetAttribute("ChargeTime", toolChargeTimeValue)
        tool:SetAttribute("DetonationPotency", toolDetonationPotencyValue)
        tool:SetAttribute("Cooldown", toolCooldownValue)
        tool:SetAttribute("Spread", toolSpreadValue)
        tool:SetAttribute("MinShots", toolMinShotsValue)
        tool:SetAttribute("MaxShots", toolMaxShotsValue)
    end
end

ArcaneHub:Checkbox(combatTab, ammoSection, 'Infinite Ammo', false, function(state)
	infinityAmmoEnabled = state
	applyWeaponTweaks()
end)
ArcaneHub:Slider(combatTab, ammoSection, 'Ammo Value', currentAmmo, function(value)
	currentAmmo = value
	applyWeaponTweaks()
end, 1, 2147483647, 1, '')
ArcaneHub:Slider(combatTab, ammoSection, 'Penetration', currentPenetration, function(value)
	currentPenetration = value
	applyWeaponTweaks()
end, 1, 2147483647, 1, '')
ArcaneHub:Slider(combatTab, ammoSection, 'Range', currentRange, function(value)
	currentRange = value
	applyWeaponTweaks()
end, 1, 2147483647, 1, '')

ArcaneHub:Checkbox(combatTab, fireSection, 'Instant Fire', false, function(state)
	instantFireEnabled = state
	applyWeaponTweaks()
end)
ArcaneHub:Slider(combatTab, fireSection, 'Fire Rate', currentFireRate, function(value)
	currentFireRate = value
	applyWeaponTweaks()
end, 1, 999, 1, ' Rnd/Sec')
ArcaneHub:Checkbox(combatTab, fireSection, 'Instant Reload', false, function(state)
	instantReloadEnabled = state
	applyWeaponTweaks()
end)
ArcaneHub:Slider(combatTab, fireSection, 'Reload Time', currentReloadTime, function(value)
	currentReloadTime = value
	applyWeaponTweaks()
end, 0, 10, 0, ' Sec')

ArcaneHub:Checkbox(combatTab, recoilSection, 'No Recoil', false, function(state)
	zeroRecoilEnabled = state
	applyWeaponTweaks()
end)
ArcaneHub:Slider(combatTab, recoilSection, 'Recoil Value', currentRecoil, function(value)
	currentRecoil = value
	applyWeaponTweaks()
end, 0, 10, 0, '')
ArcaneHub:Checkbox(combatTab, recoilSection, 'No Spread', false, function(state)
	zeroSpreadEnabled = state
	applyWeaponTweaks()
end)
ArcaneHub:Slider(combatTab, recoilSection, 'Spread Value', currentSpread, function(value)
	currentSpread = value
	applyWeaponTweaks()
end, 0, 10, 0, '')

ArcaneHub:Checkbox(miscTab, characterStatsSection, 'Enable Character Overhaul', false, function(state)
	overhaulEnabled = state
end)
ArcaneHub:Slider(miscTab, characterStatsSection, 'Dash Regen Time', dashRegenTimeValue, function(value)
	dashRegenTimeValue = value
end, 0, 5, 0, ' Sec')
ArcaneHub:Slider(miscTab, characterStatsSection, 'Ability Cooldown', cooldownValue, function(value)
	cooldownValue = value
end, 0, 5, 0, ' Sec')
ArcaneHub:Slider(miscTab, characterStatsSection, 'Utility Boost', utilityBoostValue, function(value)
	utilityBoostValue = value
end, 1, 100, 1, '')
ArcaneHub:Slider(miscTab, characterStatsSection, 'Aggro Multiplier', aggroMultiplierValue, function(value)
	aggroMultiplierValue = value
end, 1, 100, 1, 'x')

ArcaneHub:Slider(miscTab, toolCombatSection, 'Tool Firerate', toolFirerateValue, function(value)
	toolFirerateValue = value
end, 0, 10, 0, ' R/S')
ArcaneHub:Slider(miscTab, toolCombatSection, 'Tool Swingrate', toolSwingrateValue, function(value)
	toolSwingrateValue = value
end, 0, 10, 0, ' S/S')
ArcaneHub:Slider(miscTab, toolCombatSection, 'Tool Lunge Rate', toolLungeRateValue, function(value)
	toolLungeRateValue = value
end, 0, 10, 0, ' L/S')
ArcaneHub:Slider(miscTab, toolCombatSection, 'Windup Time', toolWindupValue, function(value)
	toolWindupValue = value
end, 0, 5, 0, ' Sec')
ArcaneHub:Slider(miscTab, toolCombatSection, 'Tool Spread', toolSpreadValue, function(value)
	toolSpreadValue = value
end, 0, 10, 0, '')
ArcaneHub:Slider(miscTab, toolCombatSection, 'Min Shots', toolMinShotsValue, function(value)
	toolMinShotsValue = value
end, 1, 50, 1, '')
ArcaneHub:Slider(miscTab, toolCombatSection, 'Max Shots', toolMaxShotsValue, function(value)
	toolMaxShotsValue = value
end, 1, 50, 1, '')

ArcaneHub:Slider(miscTab, toolDamageSection, 'Lifesteal %', toolLifestealValue, function(value)
	toolLifestealValue = value
end, 0, 100, 1, '%')
ArcaneHub:Slider(miscTab, toolDamageSection, 'Lunge Damage', toolLungeDamageValue, function(value)
	toolLungeDamageValue = value
end, 1, 500, 1, ' DMG')
ArcaneHub:Slider(miscTab, toolDamageSection, 'Explosion Damage', toolChargeExplodeDamageValue, function(value)
	toolChargeExplodeDamageValue = value
end, 1, 5000, 1, ' DMG')
ArcaneHub:Slider(miscTab, toolDamageSection, 'Charge Radius', toolChargeRadiusValue, function(value)
	toolChargeRadiusValue = value
end, 1, 100, 1, ' Studs')
ArcaneHub:Slider(miscTab, toolDamageSection, 'Charge Time', toolChargeTimeValue, function(value)
	toolChargeTimeValue = value
end, 0, 5, 0, ' Sec')
ArcaneHub:Slider(miscTab, toolDamageSection, 'Detonation Potency', toolDetonationPotencyValue, function(value)
	toolDetonationPotencyValue = value
end, 0, 10, 0, 'x')
ArcaneHub:Slider(miscTab, toolDamageSection, 'Tool Cooldown', toolCooldownValue, function(value)
	toolCooldownValue = value
end, 0, 5, 0, ' Sec')

ArcaneHub:CreateSettingsTab()

-- Continuously applies overhaul tweaks when enabled
task.spawn(function()
    while true do
        if overhaulEnabled then
            applyOverhaulTweaks()
        end

        task.wait(3)
    end
end)

local running = true
while running do
	ArcaneHub:Step()
	task.wait(0.0015)
end
ArcaneHub:Destroy()
