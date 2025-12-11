--[[

    🎄 Hello Jolly skidder!! 🎄

    How are you my fellow skid? I am
    surprised you got here! I'd like
    to ask for you to not skid from 
    my sources, its VERY bad quality
    and i don't think its optimized
    lol

🎁     Donate here:
    https://www.roblox.com/game-pass/1480054132/

    TODO:

]]

local Arcane = {}

--> Services
local Players = game.Players
local LocalPlayer = game.LocalPlayer

local PlaceId = game.PlaceId
local JobId = game.JobId
local Username = LocalPlayer.Name

--> Supported Games
local games = {
    [537413528] = {"Build A Boat For Treasure", "BABFT.lua"},
    [286090429] = {"Arsenal", "Arsenal.lua"},
}

local function GetGame(Id)
    local Data = games[Id]
    if not Data then
        return false, nil, nil
    end
    return true, Data[1], Data[2]
end

local IsSupported, GameName, Url = GetGame(PlaceId)

if not IsSupported then
    print("Game not supported! If this seems an error, please, report it.")
else
    print("Supported game found!")
end

print("Loading Arcane Hub..")

if Url then
    http.Get("https://raw.githubusercontent.com/LuaSecurity/Serotonin-Scripts/refs/heads/main/Content/" .. Url, {}, function(Response)
        if Response then
            loadstring(Response)()
            print("Successfully loaded Arcane! Have fun.")
        else
            warn("Couldn't load, Maybe you did something wrong?")
        end
    end)
end
