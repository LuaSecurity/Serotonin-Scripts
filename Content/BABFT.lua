local TAB_NAME = "Arcane"
local CONTAINER_NAME = "Build A Boat For Treasure"
local TOGGLE_NAME = "Auto Farm"

ui.newTab(TAB_NAME, TAB_NAME)
ui.newContainer(TAB_NAME, CONTAINER_NAME, CONTAINER_NAME)
ui.newCheckbox(TAB_NAME, CONTAINER_NAME, TOGGLE_NAME)

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

-- Moved to this position to ensure it runs in the main execution block
cheat.register("onSlowUpdate", function()
    scheduler.tick()
end)

ui.setValue("Exploits", "Misc", "Fall Speed", 0)
ui.setValue("Exploits", "Misc", "Slow Fall", "Enabled")

local positions = {
    Vector3.new(-50.31, 44, 817.38),
    Vector3.new(-53.42, 44, 1996.92),
    Vector3.new(-62.30, 44, 2764.22),
    Vector3.new(-57.29, 44, 3572.89),
    Vector3.new(-50.01, 44, 4363.34),
    Vector3.new(-39.57, 44, 5137.95),
    Vector3.new(-47.36, 44, 5958.25),
    Vector3.new(-46.75, 44, 6711.18),
    Vector3.new(-45.88, 44, 7511.21),
    Vector3.new(-42.04, 44, 8261.71),
    Vector3.new(-58.36, -360.43, 9490.37)
}

local function get_root_part()
    local player = game.LocalPlayer
    local character = player and player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return root
end

local function auto_farm_loop()
    local COOLDOWN_MS = 1800
    local DEATH_WAIT_MS = 15000

    while true do
        local is_enabled = ui.getValue(TAB_NAME, CONTAINER_NAME, TOGGLE_NAME)
        
        if is_enabled then
            for i, v in ipairs(positions) do
                if not ui.getValue(TAB_NAME, CONTAINER_NAME, TOGGLE_NAME) then
                    goto continue_loop
                end

                local root = get_root_part()

                if root then
                    for _ = 1, 3600 do
                        root.Position = v
                    end
                end

                if i < #positions then
                    if ui.getValue(TAB_NAME, CONTAINER_NAME, TOGGLE_NAME) then
                        scheduler.sleep(COOLDOWN_MS)
                    end
                end
            end
            
            if ui.getValue(TAB_NAME, CONTAINER_NAME, TOGGLE_NAME) then
                scheduler.sleep(DEATH_WAIT_MS)
            end
        end

        ::continue_loop::
        scheduler.sleep(TICK_DURATION_MS)
    end
end

scheduler.run(auto_farm_loop)
