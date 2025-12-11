local Players = game.Players
local Workspace = game.Workspace
local Camera = Workspace.CurrentCamera
local plr = game.LocalPlayer

local TAB_NAME = 'Arcane'
local CONTAINER_MAIN = 'Murder Mystery 2 Cheats'

-- State variables
-- Key: Character Instance, Value: {TargetPart, Color, Role}
local activeDrawings = {}
local cachedMap = nil

-- scheduler lib
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

-- Helper function: WorldToScreen
local function WorldToScreen(position)
    local screenX, screenY, onScreen = utility.world_to_screen(position)
    return screenX, screenY, onScreen
end

-- Retrieves the current map from workspace
local function getMap()
	if cachedMap and cachedMap.Parent == Workspace then
		return cachedMap
	end

	cachedMap = nil
	for _, v in ipairs(Workspace:GetChildren()) do
		if v:FindFirstChild("CoinContainer") then
			cachedMap = v
			return cachedMap
		end
	end
	return nil
end

-- Checks if a player is the murderer
local function GetMurder(p)
	local char = p.Character
	if not char then return end
	if p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife") then
		return true
	end
end

-- Checks if a player is the sheriff
local function GetSheriff(p)
	local char = p.Character
	if not char then return end
	if p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") then
		return true
	end
end

-- Finds the gun drop in the map
local function GetGunDrop(map)
	for _, v in ipairs(map:GetChildren()) do
		if v.Name == "GunDrop" then
			return v
		end
	end
end

-- Removes all active ESP drawings
local function clearActiveDrawings()
    activeDrawings = {}
end

-- Runs on every frame to update visual elements (ESP) using the 'draw' library
local function onPaintUpdate()
    local alpha_value = 255 -- Full Opacity

    -- 1. Player ESP Drawing (Text only)
    for character, data in pairs(activeDrawings) do
        local hrp = data.TargetPart
        local color = data.Color
        local role = data.Role

        if hrp and hrp.Parent then
            local screenX, screenY, onScreen = WorldToScreen(hrp.Position)
            
            if onScreen then
                -- Draws one fully opaque text per player (Fixed transparency by removing size param).
                local text_to_draw = string.format("[%s] %s", role, character.Name)
                
                draw.TextOutlined(
                    text_to_draw, 
                    screenX, 
                    screenY - 20, 
                    color, 
                    "Verdana", 
                    alpha_value 
                )
            end
        end
    end
    
    -- 2. Gun ESP Drawing (Box and Text)
    local gunESP = ui.getValue(TAB_NAME, CONTAINER_MAIN, 'Gun ESP')

    if gunESP then
        local map = getMap()
        local gun = map and GetGunDrop(map)
        
        if gun then
            local top3D = gun.Position + Vector3.new(0, 1, 0)
            local bottom3D = gun.Position - Vector3.new(0, 1, 0)
            
            local topX, topY, topOn = WorldToScreen(top3D)
            local bottomX, bottomY, bottomOn = WorldToScreen(bottom3D)

            if topOn and bottomOn then
                local height = math.abs(bottomY - topY)
                local width = height * 0.5
                local x = topX - width / 2
                local y = topY
                local box_color = Color3.new(1, 1, 0) -- Yellow
                
                -- Draw Box ESP for the Gun
                draw.Rect(x, y, width, height, box_color, 1.5, 0.0, alpha_value)
                
                -- Draw Text Label ("GUN") (Fixed transparency by removing size param)
                local text_size_w, _ = draw.GetTextSize("GUN", "Verdana")
                local text_x = topX - (text_size_w / 2)
                draw.TextOutlined("GUN", text_x, y - 18, box_color, "Verdana", alpha_value)
            end
        end
    end
end

-- Runs frequently for game logic and state management
local function onLogicUpdate()
	local murderESP = ui.getValue(TAB_NAME, CONTAINER_MAIN, 'Murder ESP')
	local sheriffESP = ui.getValue(TAB_NAME, CONTAINER_MAIN, 'Sheriff ESP')
	local innocentESP = ui.getValue(TAB_NAME, CONTAINER_MAIN, 'Innocent ESP')
    local autoGetGun = ui.getValue(TAB_NAME, CONTAINER_MAIN, 'Auto Get Gun')
    
    -- Rebuild this table completely every frame to eliminate stale entries
    local newDrawings = {}

	if (murderESP or sheriffESP or innocentESP) then
		-- Update state for all non-local players (No Self-ESP)
		for _, player in ipairs(Players:GetChildren()) do
			local character = player.Character
			
			if player ~= plr and character then
                local murder = GetMurder(player)
                local sheriff = GetSheriff(player)
                
                local targetColor, isVisible, role = nil, false, nil

                -- Priority check (Murderer > Sheriff > Innocent)
                if murderESP and murder then
                    targetColor = Color3.new(1, 0, 0) -- Red
                    role = "MURDERER"
                    isVisible = true
                elseif sheriffESP and sheriff then
                    targetColor = Color3.new(0, 0, 1) -- Blue
                    role = "SHERIFF"
                    isVisible = true
                elseif innocentESP and not murder and not sheriff then
                    targetColor = Color3.new(0, 1, 0) -- Green
                    role = "INNOCENT"
                    isVisible = true
                end
                
                local hrp = character:FindFirstChild("HumanoidRootPart")

                if isVisible and hrp then
                    -- Only add valid and visible characters to the new list
                    newDrawings[character] = {TargetPart = hrp, Color = targetColor, Role = role}
                end
			end
		end
        
        -- Guarantees single drawing per user by replacing the entire table
        activeDrawings = newDrawings

	else
        -- Clear all state if all ESP is disabled
        clearActiveDrawings()
    end

	-- Auto Get Gun Logic
	if autoGetGun then
		local map = getMap()
		local gun = map and GetGunDrop(map)
		local hrp = plr.Character.HumanoidRootPart
		
		if gun and hrp then
            local originalPosition = hrp.Position
            
            -- Use scheduler.setTimeout for delay
            hrp.Position = gun.Position
            scheduler.setTimeout(function()
                hrp.Position = originalPosition
            end, 300) -- 300ms delay
		end
	end
end

-- UI Setup
ui.newTab(TAB_NAME, TAB_NAME)
ui.newContainer(TAB_NAME, CONTAINER_MAIN, CONTAINER_MAIN)

-- ESP Section
ui.newCheckbox(TAB_NAME, CONTAINER_MAIN, 'Murder ESP')
ui.newCheckbox(TAB_NAME, CONTAINER_MAIN, 'Sheriff ESP')
ui.newCheckbox(TAB_NAME, CONTAINER_MAIN, 'Innocent ESP')
ui.newCheckbox(TAB_NAME, CONTAINER_MAIN, 'Gun ESP')

-- Gun Options Section
ui.newCheckbox(TAB_NAME, CONTAINER_MAIN, 'Auto Get Gun')
ui.newButton(TAB_NAME, CONTAINER_MAIN, 'Get Gun', function()
    local map = getMap()
	local gun = map and GetGunDrop(map)
	local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if gun and hrp then
        local originalPosition = hrp.Position
		hrp.Position = gun.Position
        
        -- Use scheduler.setTimeout for delay
		scheduler.setTimeout(function()
            hrp.Position = originalPosition
        end, 300) -- 300ms delay
	end
end)

-- Coin Auto Farm Placeholder
ui.newButton(TAB_NAME, CONTAINER_MAIN, 'Coin Auto Farm: (Coming Soon)', function()
    
end)

-- Register Callbacks
cheat.register("onPaint", onPaintUpdate)
cheat.register("onUpdate", onLogicUpdate) -- Runs logic at ~5ms frequency for fast updates and guaranteed cleanup

-- Register the scheduler tick on the appropriate slow update for timing
cheat.register("onSlowUpdate", function()
    scheduler.tick()
end)
