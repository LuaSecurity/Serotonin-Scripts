loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaSecurity/Matcha-Scripts/refs/heads/main/Implementations/Ui%20Library.lua"))()

repeat task.wait() until UILib ~= nil

local function getGameName()
	return _G.GameName
end

local ArcaneHub = UILib.new('Arcane Hub', Vector2.new(750, 550), {getGameName})

local combatTab = ArcaneHub:Tab('Combat')

local ammoSection = ArcaneHub:Section(combatTab, 'Ammo & Range')
local fireSection = ArcaneHub:Section(combatTab, 'Fire & Reload')
local recoilSection = ArcaneHub:Section(combatTab, 'Recoil & Spread')
local wallBangSection = ArcaneHub:Section(combatTab, 'Wall Bang')

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

local wallBangEnabled = false

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

-- Enables wall banging by moving map to ignore parts
local function applyWallBang()
	task.spawn(function()
		local map = game.Workspace:FindFirstChild("Map")
		local ignoreParts = game.Workspace:FindFirstChild("IgnoreParts")
		if map and ignoreParts then
			if wallBangEnabled then
				map.Parent = ignoreParts
			else
				map.Parent = game.Workspace
			end
		end
	end)
end

ArcaneHub:Checkbox(combatTab, ammoSection, 'Unlimited Ammo', false, function(state)
	infinityAmmoEnabled = state
	applyWeaponTweaks()
end)
ArcaneHub:Slider(combatTab, ammoSection, 'Magazine Size', currentAmmo, function(value)
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

ArcaneHub:Checkbox(combatTab, fireSection, 'Rapid Fire', false, function(state)
	instantFireEnabled = state
	applyWeaponTweaks()
end)
ArcaneHub:Slider(combatTab, fireSection, 'Max Fire Rate', currentFireRate, function(value)
	currentFireRate = value
	applyWeaponTweaks()
end, 1, 10000, 1, ' Rnd/Sec')
ArcaneHub:Checkbox(combatTab, fireSection, 'Instant Reload', false, function(state)
	instantReloadEnabled = state
	applyWeaponTweaks()
end)
ArcaneHub:Slider(combatTab, fireSection, 'Reload Time', currentReloadTime, function(value)
	currentReloadTime = value
	applyWeaponTweaks()
end, 0, 10, 0.1, ' Sec')

ArcaneHub:Checkbox(combatTab, recoilSection, 'No Recoil', false, function(state)
	zeroRecoilEnabled = state
	applyWeaponTweaks()
end)
ArcaneHub:Slider(combatTab, recoilSection, 'Recoil Reduction', currentRecoil, function(value)
	currentRecoil = value
	applyWeaponTweaks()
end, 0, 10, 0.1, '')
ArcaneHub:Checkbox(combatTab, recoilSection, 'No Spread', false, function(state)
	zeroSpreadEnabled = state
	applyWeaponTweaks()
end)
ArcaneHub:Slider(combatTab, recoilSection, 'Spread Reduction', currentSpread, function(value)
	currentSpread = value
	applyWeaponTweaks()
end, 0, 10, 0.1, '')

ArcaneHub:Checkbox(combatTab, wallBangSection, 'Enable Wall Bang', false, function(state)
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
