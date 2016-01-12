
Running = false
FlagShader = false
Teams = false

local teamCount = 0
local screenWidth, screenHeight = guiGetScreenSize()
local scale = math.max(0.80, screenWidth / 1920)
local iconSize = 64 * scale

function startMapMode()
    -- Check if mode is running
    if Running then
        stopMapMode()
    end
    
    -- Create table for flag shaders (automatically filled)
    FlagShader = {}
    
    -- Gather team information
    Teams = {}
    teamCount = 0
    
    for index, team in pairs(Element.getAllByType("team", resourceRoot)) do
        local r, g, b = team:getColor()
        Teams[team] = {r = r, g = g, b = b, int = tocolor(r, g, b)}
        teamCount = teamCount + 1
    end
    
    -- Add renderer for flag score
    addEventHandler("onClientRender", root, onFlagScoreRender)
    
    -- Update state
    Running = true
end

function stopMapMode()
    -- Check if mode is stopped
    if not Running then
        return
    end
    
    -- Add renderer for flag score
    removeEventHandler("onClientRender", root, onFlagScoreRender)
    
    -- Destroy table with teams
    Teams = false
    
    -- Destroy table with flag shaders
    for flag, shader in pairs(FlagShader) do
        shader:destroy()
    end
    
    FlagShader = false
    
    -- Update state
    Running = false
end

function onFlagScoreRender()
    -- Check if we have a valid teams cache
    if not Teams then
        return
    end
    
    -- Calculate height and position (right, center)
    local height = teamCount * iconSize
    local xstart = screenWidth - iconSize
    local ystart = (screenHeight - height) / 2
    local yoffset = 10 * scale
    local index = 0
    
    -- Cache player's team
    local myTeam = localPlayer.team
    
    -- Draw teams and score
    for team, data in pairs(Teams) do
        if isElement(team) then
            -- Update team color if neccessary
            local r, g, b = team:getColor()
            
            if data.r ~= r or data.g ~= g or data.b ~= b then
                data = updateFlagTeamColor(team, r, g, b)
            end
            
            -- Calculate relative y-position
            local y = ystart + iconSize * index
            
            -- Draw flag
            dxDrawImage(xstart, y, iconSize, iconSize, "assets/flag.png", 0, 0, 0, data.int, true)
            
            -- Draw score
            local score = team:getData("flagscore") or 0
            dxDrawText(score, xstart + 1, y + 1 + yoffset, xstart + iconSize, nil, -16777216, 1.0 * scale, "default-bold", "center", "top", false, false, true)
            dxDrawText(score, xstart, y + yoffset, xstart + iconSize, nil, -1, 1.0 * scale, "default-bold", "center", "top", false, false, true)
            
            -- Draw 'Your Team' tag
            if team == myTeam then
                dxDrawText("Your Team", xstart, y + iconSize / 2, nil, nil, -1, 1.0 * scale, "default-bold", "center", "center", false, false, true, false, true, 270)
            end
            
            index = index + 1
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
            teamCount = teamCount - 1
            Teams[source] = nil
            return
        end
        
        if FlagShader and FlagShader[source] then
            FlagShader[source]:destroy()
            FlagShader[source] = nil
        end
    end
)

function isFlag(element)
    return source.type == "object" and source.model == 2993 and Teams[source:getData("team")]
end

function createFlagShader(flag, color)
    if not isFlag(flag) then
        return nil
    end
    
    if FlagShader[flag] then
        return FlagShader[flag]
    end
    
    local shader = DxShader("assets/flag.fx", 1, 0, false, "object")
    
    if not shader then
        return nil
    end
    
    if not shader:applyToWorldTexture("*", flag) then
        shader:destroy()
        return nil
    end
    
    shader:setValue("flagColor", color.r, color.g, color.b)
    
    return shader
end

function updateFlagTeamColor(team, r, g, b)
    -- Create new color table and apply it
    local new = {r = r, g = g, b = b, int = tocolor(r, g, b)}
    Teams[team] = new
    
    -- Try to update shader color
    local flag = team:getData("flag")
    
    if flag and FlagShader[flag] then
        updateFlagShaderColor(flag)
    end
    
    return new
end

function updateFlagShaderColor(flag)
    local shader = FlagShader[flag]
    
    if not shader then
        return
    end
    
    shader:setValue("flagColor", color.r, color.g, color.b)
end
