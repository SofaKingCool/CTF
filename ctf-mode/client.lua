
TeamCount = 0
Teams = false
Running = false
FlagShader = false
ScreenWidth, ScreenHeight = guiGetScreenSize()
Scale = math.max(0.80, ScreenWidth / 1920)
IconSize = 64 * Scale

function startMapMode()
    -- Check if mode is running
    if Running then
        stopMapMode()
    end
    
    -- Create table for flag shaders (automatically filled)
    FlagShader = {}
    
    -- Prepare team related variables
    Teams = {}
    TeamCount = 0
    
    -- Gather team information (created by this resource)
    for index, team in pairs(Element.getAllByType("team", resourceRoot)) do
        -- Get the team's color
        local r, g, b = team:getColor()
        
        -- Create the structure for this team
        Teams[team] = {r = r, g = g, b = b, int = tocolor(r, g, b)}
        
        -- Increment team counter
        TeamCount = TeamCount + 1
    end
    
    -- Add renderer for flag score
    addEventHandler("onClientRender", root, onFlagScoreRender)
    
    -- Set state to running
    Running = true
end

function stopMapMode()
    -- Check if mode is stopped
    if not Running then
        return
    end
    
    -- Remove renderer for flag score
    removeEventHandler("onClientRender", root, onFlagScoreRender)
    
    -- Reset team related variables
    Teams = false
    TeamCount = 0
    
    -- Destroy flag shaders
    for flag, shader in pairs(FlagShader) do
        shader:destroy()
    end
    
    -- Reset table for flag shaders
    FlagShader = false
    
    -- Set state to stopped
    Running = false
end

function onFlagScoreRender()
    -- Check if we have a valid teams cache
    if not Teams then
        return
    end
    
    -- Calculate height and position (right, center)
    local scoreHeight = TeamCount * IconSize
    local topX = ScreenWidth - IconSize
    local topY = (ScreenHeight - scoreHeight) / 2
    local screenBorderOffset = 10 * Scale
    local teamPosition = 0
    
    -- Cache player's team
    local myTeam = localPlayer.team
    
    -- Draw team scoreboard (right, center)
    for team, data in pairs(Teams) do
        if isElement(team) then
            -- Update team color if neccessary
            local r, g, b = team:getColor()
            
            if data.r ~= r or data.g ~= g or data.b ~= b then
                data = updateFlagTeamColor(team, r, g, b)
            end
            
            -- Calculate relative y-position
            local y = topY + IconSize * teamPosition
            
            -- Draw flag
            dxDrawImage(topX, y, IconSize, IconSize, "assets/flag.png", 0, 0, 0, data.int, true)
            
            -- Draw score
            local score = team:getData("flagscore") or 0
            dxDrawText(score, topX + 1, y + 1 + screenBorderOffset, topX + IconSize, nil, -16777216, 1.0 * Scale, "default-bold", "center", "top", false, false, true)
            dxDrawText(score, topX, y + screenBorderOffset, topX + IconSize, nil, -1, 1.0 * Scale, "default-bold", "center", "top", false, false, true)
            
            -- Draw 'Your Team' tag
            if team == myTeam then
                dxDrawText("Your Team", topX, y + IconSize / 2, nil, nil, -1, 1.0 * Scale, "default-bold", "center", "center", false, false, true, false, true, 270)
            end
            
            -- Increment team position
            teamPosition = teamPosition + 1
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot,
    function ()
        triggerServerEvent("CTF:onPlayerResourceStart", resourceRoot)    
    end,
false)

addEvent("CTF:onClientMatchStart", true)
addEventHandler("CTF:onClientMatchStart", resourceRoot,
    function ()
        startMapMode()
    end,
false)

addEventHandler("onClientResourceStop", resourceRoot,
    function ()
        stopMapMode()
    end,
false)

addEventHandler("onClientElementStreamIn", root,
    function ()
        if not Running or not isFlag(source) then
            return
        end
        
        local color = Teams[source:getData("team")]
        FlagShader[source] = createFlagShader(source, color)
    end
)

addEventHandler("onClientElementStreamOut", root,
    function ()
        if not Running or not FlagShader[source] then
            return
        end
        
        FlagShader[source]:destroy()
        FlagShader[source] = nil
    end
)

addEventHandler("onClientElementDestroy", root,
    function ()
        if not Running then
            return
        end
        
        if Teams and Teams[source] then
            TeamCount = TeamCount - 1
            Teams[source] = nil
            return
        end
        
        if FlagShader and FlagShader[source] then
            FlagShader[source]:destroy()
            FlagShader[source] = nil
        end
    end
)

addEventHandler("onClientVehicleEnter", root,
    function ()
        if not Running then
            return
        end
        
        if not source.controller or (not source.blown and source.health > 250) then
            return
        end
        
        -- Fix vehicle to prevent respawn explosions
        source:fix()
    end
)

function isFlag(element)
    return element.type == "object" and element.model == 2993 and Teams[element:getData("team")]
end

function createFlagShader(flag, color)
    -- Verify flag element
    if not isFlag(flag) then
        return nil
    end
    
    -- Do nothing if shader exists
    if FlagShader[flag] then
        return FlagShader[flag]
    end

    -- Create shader for each flag    
    local shader = DxShader("assets/flag.fx", 1, 0, false, "object")
    
    if not shader then
        return nil
    end
    
    -- Apply shader to each flag texture
    if not shader:applyToWorldTexture("*", flag) then
        shader:destroy()
        return nil
    end
    
    -- Apply team color
    shader:setValue("flagColor", color.r, color.g, color.b)
    
    return shader
end

function updateFlagTeamColor(team, r, g, b)
    -- Create new color table and apply it
    local new = {r = r, g = g, b = b, int = tocolor(r, g, b)}
    Teams[team] = new
    
    -- Update shader color
    local flag = team:getData("flag")
    updateFlagShaderColor(flag)
    
    return new
end

function updateFlagShaderColor(flag)
    -- Verify flag element
    if not isFlag(flag) then
        return false
    end
    
    -- Get the flag's shader
    local shader = FlagShader[flag]
    
    if not shader then
        return false
    end
    
    -- Change the flag color
    shader:setValue("flagColor", color.r, color.g, color.b)
    
    return true
end
