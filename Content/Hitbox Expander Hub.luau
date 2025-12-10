loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaSecurity/Matcha-Scripts/refs/heads/main/Implementations/Ui%20Library.lua"))()

repeat task.wait() until UILib ~= nil

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function getGameName()
    return "Universal Expander"
end

local myGui = UILib.new('Arcane Hub', Vector2.new(400, 320), {getGameName})

local visualsTab = myGui:Tab('Visuals')
local expanderSection = myGui:Section(visualsTab, 'Body Part Expander')

local enableExpander = false
local teamCheck = false
local sizeX, sizeY, sizeZ = 5, 5, 5
local selectedParts = {}

local allParts = {
    'Head',
    'UpperTorso',
    'Torso',
    'HumanoidRootPart',
    'LowerTorso',
    'Left Arm',
    'Right Arm',
    'Left Leg',
    'Right Leg'
}

myGui:Checkbox(visualsTab, expanderSection, 'Enable Expander', false, function(state)
    enableExpander = state
end)

myGui:Checkbox(visualsTab, expanderSection, 'Only Expand Enemies', false, function(state)
    teamCheck = state
end)

myGui:Choice(visualsTab, expanderSection, 'Body Parts', {}, function(values)
    selectedParts = values
end, allParts, true)

myGui:Slider(visualsTab, expanderSection, 'Size X', sizeX, function(value)
    sizeX = value
end, 1, 50, 1, '')

myGui:Slider(visualsTab, expanderSection, 'Size Y', sizeY, function(value)
    sizeY = value
end, 1, 50, 1, '')

myGui:Slider(visualsTab, expanderSection, 'Size Z', sizeZ, function(value)
    sizeZ = value
end, 1, 50, 1, '')

-- Expands selected body parts of players based on settings
local function expandParts()
    if not enableExpander then return end
    for _, player in ipairs(Players:GetChildren()) do
        if player ~= localPlayer then
            if not teamCheck or (player.Team ~= localPlayer.Team) then
                local char = player.Character
                if char then
                    for _, partName in ipairs(selectedParts) do
                        local part = char:FindFirstChild(partName)
                        if part then
                            part.Size = Vector3.new(sizeX, sizeY, sizeZ)
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end

myGui:CreateSettingsTab()

local running = true

task.spawn(function()
    while running do
        expandParts()
        task.wait(1)
    end
end)

while running do
    myGui:Step()
    task.wait(0.0015)
end

myGui:Destroy()
