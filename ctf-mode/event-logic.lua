
RaceState = "undefined"
LoadedClient = {}

addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging", root,
    function (newState)
        -- Update our race state
        RaceState = newState
        
        if newState == "NoMap" or newState == "PostFinish" then
            -- Stop the map mode when the round ends
            stopMapMode()
        end
    end
)

addEvent("onMapStarting")
addEventHandler("onMapStarting", root,
    function ()
        -- Does the current map support the mode?
        if not isMapSupportAvailable() then
            return outputDebugString("[CTF] Map is not supported")
        end
        
        -- Start map mode now
        startMapMode()
    end
)

addEventHandler("onResourceStart", resourceRoot,
    function ()
        -- Try to fetch the current race state (default race does not support this)
        raceState = getCurrentRaceState()
        
        if raceState ~= "Running" or raceState ~= "MidMapVote" then
            return
        end
        
        -- Does the current map support the mode?
        if not isMapSupportAvailable() then
            return
        end
        
        -- Start map mode now
        startMapMode()
    end
)

addEvent("CTF:onPlayerResourceStart", true)
addEventHandler("CTF:onPlayerResourceStart", resourceRoot,
    function ()
        LoadedClient[client] = true
        
        if Running then
            -- Announce start on clientside
            triggerClientEvent(client, "CTF:onClientMatchStart", resourceRoot)
        end
    end
)

addEventHandler("onResourceStop", resourceRoot,
    function ()
        -- Stop the map mode if it's not stopped yet
        stopMapMode()
    end,
false, "high")

addEventHandler("onPlayerVehicleEnter", root,
    function (vehicle, seat)
        -- Check if map mode is running
        if not Running then
            return
        end
        
        -- Get the player's team
        local playerTeam = source.team
        
        if not playerTeam then
            playerTeam = getFlagTeamForPlayer()
            source:setTeam(playerTeam)
        end
        
        -- Does the player drive the car?
        if seat ~= 0 then
            return
        end
        
        -- Update vehicle color to match team
        local r, g, b = playerTeam:getColor()
        vehicle:setColor(r, g, b, r, g, b, r, g, b, r, g, b)
        
        -- Get the spawnpoint list
        local spawnpointList = Spawnpoints[playerTeam]
        
        if not next(spawnpointList) then
            return
        end
        
        -- Move player to a free spawnpoint on his team-side
        local spawnpoint = spawnpointList[math.random(#spawnpointList)]
        
        if not isElement(spawnpoint) then
            return
        end
        
        vehicle:setPosition(spawnpoint.position)
        vehicle:setRotation(0, 0, spawnpoint:getData("rotZ"))
    end
)

addEventHandler("onPlayerWasted", root,
    function ()
        -- Check if map mode is running
        if not Running then
            return
        end    
        
        -- Drop the flag if the player carries one
        if FlagPlayer[source] then
            dropTeamFlag(source)
        end
    end,
true, "high")

addEventHandler("onPlayerQuit", root,
    function ()
        -- Free memory
        LoadedClient[source] = nil
        
        -- Check if map mode is running
        if not Running then
            return
        end 
        
        -- Drop the flag for the leaving player
        if FlagPlayer[source] then
            dropTeamFlag(source)
            FlagPlayer[source] = nil
        end
    end
)
