
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
