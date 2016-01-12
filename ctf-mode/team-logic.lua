
TeamList = {}

function createFlagTeam(id, marker)
    -- Color and position of the marker
    local r, g, b = marker:getColor()
    local position = marker:getPosition()
    
    -- Create the team itself
    local name = "Team ".. id
    local team = Team(name, r, g, b)
    
    if not team then
        return nil
    else
        TeamList[team] = true
        team:setPosition(position)
    end
    
    -- Create the flag
    local flag = Object(2993, position)
    
    if not flag then
        destroyFlagTeam(team)
        return nil
    else
        flag:setScale(8)
        flag:setData("team", team)
        team:setData("flag", flag)
    end
    
    -- Create the base colshape
    local base = ColShape.Sphere(position, 8)
    
    if not base then
        destroyFlagTeam(team)
        return nil
    else
        base:setData("team", team)
        team:setData("base", base)
        addEventHandler("onColShapeHit", base, onElementBaseHit)
    end
    
    -- Set other team data
    team:setData("in-base", true)
    team:setData("carrier", false)
    team:setData("rescue-marker", false)
    team:setData("z-offset", false)
    team:setData("flagscore", 0)
    
    return team
end

function destroyFlagTeam(team)
    -- Verify the team element
    if not isElement(team) or team.type ~= "team" then
        return
    end
    
    -- Destroy the rescue marker
    destroyTeamFlagRescueMarker(team)
    
    -- Destroy the base colshape
    local base = team:getData("base")
    
    if base then
        removeEventHandler("onColShapeHit", base, onElementBaseHit)
        base:destroy()
    end
    
    -- Destroy the flag
    local flag = team:getData("flag")
    
    if flag then
        flag:destroy()
    end
    
    -- Destroy the team
    TeamList[team] = nil
    team:destroy()
end

function getFlagTeamSpawnpoints(team)
    -- Table for spawnpoints
    local spawnpoints = {}
    
    -- Get the other team positions
    local positionList = {}
    
    for index, otherTeam in pairs(Teams) do
        positionList[otherTeam] = otherTeam:getPosition()
    end
    
    -- Iterate through the spawnpoints
    for index, spawnpoint in pairs(Element.getAllByType("spawnpoint")) do
        -- Find the nearest team base
        local spawnpointPosition = spawnpoint:getPosition()
        local nearestTeam, nearestDistance = false, 300
        
        for team, position in pairs(positionList) do
            local distance = (spawnpointPosition - position):getLength()
            
            if distance < nearestDistance then
                nearestDistance = distance
                nearestTeam = team
            end
        end
        
        -- Add the spawnpoint to the list
        if nearestTeam == team then
            spawnpoints[#spawnpoints + 1] = spawnpoint
        end
    end
    
    return spawnpoints
end

function onElementBaseHit(element, matchingDimension)
    -- Check if we should process this event dispatch
    if not matchingDimension or element.type ~= "player" then
        return
    end
    
    -- Verify the player's team
    local playerTeam = element:getTeam()
    
    if not playerTeam or not TeamList[playerTeam] then
        return
    end
    
    -- Get the player's vehicle
    local vehicle = callResourceFunction("race", "getPlayerVehicle", element)
    
    if not vehicle then
        return
    end
    
    -- Verify the base's team
    local baseTeam = source:getData("team")
    
    if not baseTeam or not TeamList[baseTeam] then
        return
    end
    
    return onTeamPlayerBaseHit(element, vehicle, playerTeam, baseTeam)
end

function getFlagTeamForPlayer()
    if not Teams then
        return false
    end

    local flagTeam, lowestCount = false, 1024
    
    for index, team in pairs(Teams) do
        if isElement(team) then
            local playerCount = team:countPlayers()
            
            if playerCount < lowestCount then
                flagTeam = team
                lowestCount = playerCount
            end
        end
    end
    
    return flagTeam 
end

function createTeamFlagRescueMarker(team)
    -- Check if the rescue marker exists
    if team:getData("rescue-marker") then
        return
    end
    
    -- Get the team's flag
    local flag = team:getData("flag")
    
    if not flag then
        return
    end
    
    -- Create the marker
    local r, g, b = team:getColor()
    local marker = Marker(flag.position, "cylinder", 5.0, r, g, b)
    
    if not marker then
        return
    end
    
    -- Set marker data
    marker:setData("team", team)
    team:setData("rescue-marker", marker)
    addEventHandler("onMarkerHit", marker, onElementRescueMarkerHit)
end

function destroyTeamFlagRescueMarker(team)
    -- Get the rescue marker
    local marker = team:getData("rescue-marker")
    
    if not isElement(marker) then
        return
    end
    
    -- Destroy the rescue marker
    removeEventHandler("onMarkerHit", marker, onElementRescueMarkerHit)
    marker:destroy()
    
    -- Update team data
    team:setData("rescue-marker", false)
end

function onElementRescueMarkerHit(element, matchingDimension)
    -- Check if we should process this event dispatch
    if not matchingDimension or element.type ~= "player" then
        return
    end
    
    -- Verify the player's team
    local playerTeam = element:getTeam()
    
    if not playerTeam or not TeamList[playerTeam] then
        return
    end
    
    -- Get the player's vehicle
    local vehicle = callResourceFunction("race", "getPlayerVehicle", element)
    
    if not vehicle then
        return
    end
    
    -- Verify the base's team
    local markerTeam = source:getData("team")
    
    if not markerTeam or not TeamList[markerTeam] then
        return
    end
    
    return onTeamPlayerRescueMarkerHit(element, vehicle, playerTeam, markerTeam)
end
