
-- mixed callResourceFunction( string resourceName, string functionName, args... )
function callResourceFunction(resourceName, functionName, ...)
    local resource = Resource.getFromName(resourceName)
    
    if resource and resource:getState() == "running" then
        return call(resource, functionName, ...)
    else
        return nil
    end
end

-- table getTeamFlagMarkers( )
function getTeamFlagMarkers()
    local markerList = {}
    
    for index, marker in pairs(Element.getAllByType("marker")) do
        if marker:getSize() == 5 then
            markerList[marker] = true
        end
    end
    
    return markerList
end

-- boolean isMapSupportAvailable( )
function isMapSupportAvailable()
    local markers = getTeamFlagMarkers()
    return next(markers) ~= nil
end

-- string getCurrentRaceState( )
function getCurrentRaceState()
    local raceResource = Resource.getFromName("race")
    
    if not raceResource then
        return "undefined"
    end
    
    local raceResourceRoot = raceResource:getRootElement()
    return raceResourceRoot and raceResourceRoot:getData("state") or "undefined" 
end

-- nil destroyEveryTeam( )
function destroyEveryTeam()
    for index, team in pairs(Element.getAllByType("team")) do
        team:destroy()
    end
    
    return nil
end

-- nil enableServerTeams( )
function enableServerTeams()
    -- TODO: Here you can enable your server's autoteams (there are no teams on the server here)
end

-- nil disableServerTeams( )
function disableServerTeams()
    -- TODO: Here you can disable your server's autoteams (you dont have to delete the teams)
end

-- nil createScoreboardColumn( )
function createScoreboardColumn()
    callResourceFunction("scoreboard", "scoreboardAddColumn", "flagscore", root, 50, "Score")
end

-- nil destroyScoreboardColumn( )
function destroyScoreboardColumn()
    callResourceFunction("scoreboard", "scoreboardRemoveColumn", "flagscore")
end

-- boolean|element getPlayerFreeSpawnpoint( element player, number spaceThreshold )
function getPlayerFreeSpawnpoint(player, spaceThreshold)
    -- Check if spawnpoint table is available
    if not player or not Spawnpoints then
        return false
    end
    
    -- Get the player's team
    local playerTeam = player:getTeam()
    local spawnpointList = playerTeam and Spawnpoints[playerTeam]
    
    if not playerTeam or not spawnpointList then
        return false
    end
    
    -- Pick the first spawnpoint if only one is available 
    local spawnpointCount = #spawnpointList
    
    if spawnpointCount == 1 then
        return spawnpointList[1]
    end
    
    -- Cache the player list
    local playerList = Element.getAllByType("player")
    
    -- Pick a random spawnpoint if player is alone
    local playerCount = #playerList
    
    if playerCount == 1 then
        return spawnpointList[math.random(spawnpointCount)]
    end
    
    -- Random start-index for spawnpoints
    local offset = math.random(spawnpointCount)
    
    -- Find the spawnpoint with the highest amount of space
    local bestSpawnpoint, highestSpace = false, 0
    
    for sp = 1, spawnpointCount do
        -- Create variables for current spawnpoint
        local spawnpoint = spawnpointList[(sp + offset) % spawnpointCount + 1]
        local spawnpointPosition = spawnpoint:getPosition()
        local space = false
        
        -- Iterate through players to find the lowest distance (= space)
        for pl = 1, playerCount do
            local somebody = playerList[pl]
            
            if somebody ~= player then
                local distance = (spawnpointPosition - somebody.position):getLength()
                
                if not space or distance < space then
                    space = distance
                end
            end
        end 
        
        -- Use the spawnpoint when it offers more space
        if space and space > highestSpace then
            bestSpawnpoint = spawnpoint
            highestSpace = space
            
            -- Stop iteration if spawnpoint has more space than required
            if highestSpace >= spaceThreshold then
                break
            end
        end
    end
    
    return bestSpawnpoint
end
