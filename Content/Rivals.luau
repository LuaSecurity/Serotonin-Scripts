loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaSecurity/Matcha-Scripts/refs/heads/main/Implementations/Ui%20Library.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaSecurity/Matcha-Scripts/refs/heads/main/Implementations/NotificationModule.lua"))()

repeat task.wait() until UILib ~= nil
repeat task.wait() until notify ~= nil

local function getGameName()
    return "Rivals"
end

local Admins = {
    180434077,
    478848349,
    7171389384,
    164100188,
    163180763,
    549095619,
    224264658,
    99268362,
    131577796,
    3161872154,
    1602256048,
    1302259915,
    39560492,
    475975042,
    877654864,
    754154414,
    31598456,
    1399517213,
    113947873,
    133321104,
    15941965,
    20349956
}

local AdminCache = {}
local StaffNotifierEnabled = true

local function isAdmin(player)
    for _, adminId in pairs(Admins) do
        if player.UserId == adminId then
            return true
        end
    end
    return false
end

local function notifyAdminFound(player)
    notify.CreateNotification("Arcane Hub", "Admin " .. player.Name .. " is in your session.", 5, 10, nil, nil, Color3.fromRGB(150, 40, 100))
end

local function startAdminDetector()
    while true do
        if AdminDetectionEnabled then
            for _, child in pairs(game["Players "]:GetChildren()) do
                if child:IsA("Player") then
                    if isAdmin(child) then
                        if not AdminCache[child.UserId] then
                            AdminCache[child.UserId] = true
                            notifyAdminFound(child)
                        end
                    end
                end
            end
        end
        task.wait(2)
    end
end

local ArcaneHub = UILib.new('Arcane Hub', Vector2.new(450, 600), {getGameName})

local RageTab = ArcaneHub:Tab('Rage')
local VisualsTab = ArcaneHub:Tab('Visuals')
local MovementTab = ArcaneHub:Tab('Movement')
local MiscTab = ArcaneHub:Tab('Misc')

local RageSection = ArcaneHub:Section(RageTab, 'General')



local VisualsSection = ArcaneHub:Section(VisualsTab, 'General')



local MovementSection = ArcaneHub:Section(MovementTab, 'General')



local MiscSection = ArcaneHub:Section(MiscTab, 'Utilities')

ArcaneHub:Checkbox(MiscTab, MiscSection, 'Staff notifier', true, function(state)
    StaffNotifierEnabled = state
end)

ArcaneHub:CreateSettingsTab()
notify.CreateNotification("Arcane Hub", "Successfully Loaded.", 5, 10, nil, nil, Color3.fromRGB(70, 40, 100))

local running = true

task.spawn(startAdminDetector)

while running do
    ArcaneHub:Step()
    wait(0.0015)
end

ArcaneHub:Destroy()