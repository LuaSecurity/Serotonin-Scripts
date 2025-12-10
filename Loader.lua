--[[

    🎄 Hello Jolly skidder!! 🎄

    How are you my fellow skid? I am
    surprised you got here! I'd like
    to ask for you to not skid from 
    my sources, its VERY bad quality
    and i don't think its optimized
    lol

🎁     Donate here:
    https://www.roblox.com/game-pass/1480054132/

    TODO:

]]

local Arcane = {}

local scheduler = {}

local TICK_DURATION_MS = 1000
local current_time = 0
local sleeping = {}

function scheduler.sleep(ms)
    local co = coroutine.running()
    if not co then
        error("scheduler.sleep() must be called inside a coroutine")
    end
    sleeping[#sleeping + 1] = {
        co = co,
        wake_time = current_time + ms
    }
    coroutine.yield()
end

function scheduler.run(fn)
    local co = coroutine.create(fn)
    coroutine.resume(co)
end

function scheduler.setTimeout(fn, delay)
    scheduler.run(function()
        scheduler.sleep(delay)
        fn()
    end)
end

function scheduler.tick()
    current_time = current_time + TICK_DURATION_MS

    for i = #sleeping, 1, -1 do
        local task = sleeping[i]
        if current_time >= task.wake_time then
            table.remove(sleeping, i)
            coroutine.resume(task.co)
        end
    end
end

cheat.register("onSlowUpdate", function()
    scheduler.tick()
end)

--> Services
local Players = game.Players
local LocalPlayer = game.LocalPlayer

local PlaceId = game.PlaceId
local JobId = game.JobId
local Username = LocalPlayer.Name

--> Supported Games
local games = {
  [537413528] = {"Build A Boat For Treasure", "BABFT.luau"}
}

local function GetGame(Id)
  local Data = games[Id]
  if not Data then
    return false, nil, nil
  end
  return true, Data[1], Data[2]
end

local IsSupported, GameName, Url = GetGame(PlaceId)

scheduler.run(function()
    if not IsSupported then
      print("Game not supported! If this seems an error, please, report it.")
    else
      print("Supported game found!")
    end
    scheduler.sleep(1000)
    print("Loading Arcane Hub..")
    scheduler.sleep(1000)

    if Url then
      http.Get("https://raw.githubusercontent.com/LuaSecurity/Serotonin-Scripts/refs/heads/main/Content/", {}, function(Response)
        if Response then
           loadstring(Response)()
          else
            warn("Couldn't load, Maybe you did something wrong?")
        end
      end)
    end
end)
