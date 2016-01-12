
Running = false
Teams = false
Spawnpoints = false

function startMapMode()
    -- Check if mode is running
    if Running then
        return false
    end
    
    -- Get markers for both teams
    local markers = getTeamFlagMarkers()
    
    if not next(markers) then
        return false
    end
    
    -- Disable teams created by the server
    disableServerTeams()
    
    -- Destroy existing teams
    destroyEveryTeam()
    
    -- Create table for flag holders
    FlagPlayer = {}
    
    -- Create table for teams
    Teams = {}
    
    for marker in pairs(markers) do
        local id = #Teams + 1
        Teams[id] = createFlagTeam(id, marker)
    end
    
    -- Create table for spawnpoints
    Spawnpoints = {}
    
    for index, team in pairs(Teams) do
        local spawnpointList = getFlagTeamSpawnpoints(team)
        Spawnpoints[team] = spawnpointList
    end
    
    -- Split the players into our teams
    math.randomseed(getTickCount())
    local playerList = Element.getAllByType("player")
    
    while (#playerList > 0) do
        local player = table.remove(playerList, math.random(#playerList))
        local state = player:getData("state")
        
        if state == "waiting" or state == "alive" or state == "dead" or state == "not ready" then
            local team = getFlagTeamForPlayer()
            player:setTeam(team)
        end
    end
    
    -- Create scoreboard column
    -- createScoreboardColumn()
    
    -- Developer information
    outputDebugString("[CTF] Mode has been started")
    
    -- Update global variables
    Running = true
    
    -- Announce start on clientside
    triggerClientEvent("CTF:onClientMatchStart", resourceRoot)
    
    -- Dispatch event
    -- triggerEvent("CTF:onStart", resourceRoot)
    
    return true
end

function stopMapMode()
    -- Check if mode is running
    if not Running then
        return false
    end
    
    -- Dispatch event
    -- triggerEvent("CTF:onStop", resourceRoot)
    
    -- Destroy every flag team
    for index, team in pairs(Teams) do
        destroyFlagTeam(team)
    end
    
    -- Destroy scoreboard column
    -- destroyScoreboardColumn()
    
    -- Destroy existing teams
    destroyEveryTeam()
    
    -- Enable teams created by the server
    enableServerTeams()
    
    -- Developer information
    outputDebugString("[CTF] Mode has been stopped")
    
    -- Update global variables
    Teams = false
    Running = false
    Spawnpoints = false
    FlagPlayer = {}
    
    return true
end
