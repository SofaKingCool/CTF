
FlagPlayer = {}

function onTeamPlayerBaseHit(player, vehicle, playerTeam, baseTeam)
    -- Pickup the enemy flag in their base
    -- [In enemy base, Flag in base, Player doesn't carry any flag]
    if playerTeam ~= baseTeam and baseTeam:getData("in-base") and not FlagPlayer[player] then
        -- Give the player the enemy flag
        return givePlayerTeamFlag(player, vehicle, baseTeam)
    end
    
    -- Player stands in his home base
    if playerTeam == baseTeam then
        -- [Flag not in base, Player holds the flag]
        if not baseTeam:getData("in-base") and baseTeam:getData("carrier") == player then
            -- Return flag to home base
            return moveTeamFlagToBase(baseTeam)
        end
        
        -- Check if home-flag is in base
        if playerTeam:getData("in-base") then
            -- Check if we hold the enemy flag
            local flagTeam = FlagPlayer[player]
            
            if flagTeam then 
                -- [Player holds enemy flag]
                if flagTeam ~= baseTeam then
                    -- Dispatch event
                    -- if next(LoadedClient) then
                    --     triggerEvent("CTF:onTeamScore", baseTeam, player)
                    -- end
                    
                    -- Increase score for team
                    baseTeam:setData("flagscore", (baseTeam:getData("flagscore") or 0) + 1)
                    
                    -- Move enemy flag to its base
                    return moveTeamFlagToBase(flagTeam)
                end
            end
        end
    end
end

function onTeamPlayerRescueMarkerHit(player, vehicle, playerTeam, markerTeam)
    -- Check if player carries a flag
    if FlagPlayer[player] then
        return
    end

    -- Destroy the rescue marker
    destroyTeamFlagRescueMarker(markerTeam)
    
    -- Check if we pickup our flag
    if playerTeam == markerTeam then 
        -- TODO: Check if our flag is not being held by any enemy (might be on ground)
        if not playerTeam:getData("in-base") then
            -- Pickup flag if our own flag is not in base
            givePlayerTeamFlag(player, vehicle, markerTeam)
        else
            -- Else return flag to home base 
            moveTeamFlagToBase(markerTeam)
        end
    else
        -- Pickup flag
        givePlayerTeamFlag(player, vehicle, markerTeam)
        
        -- TODO: Check if team member has team flag => teleport team flag to base
    end
end

function givePlayerTeamFlag(player, vehicle, team)
    -- Get the team's flag
    local flag = team:getData("flag")
    
    if not flag then
        return false
    end
    
    -- Calculate the z-offset if needed
    if not team:getData("z-offset") then
        local basePosition = team:getPosition()
        local vehiclePosition = vehicle:getPosition()
        local offset = (basePosition - vehiclePosition)
        team:setData("z-offset", offset.z)
    end
    
    -- Attach the flag to the vehicle
    flag:attach(vehicle, 0, 0, 0, 0, 0, -90)
    flag:setCollisionsEnabled(false)
    flag:setFrozen(true)
    flag:setScale(3)
    
    -- Update team data
    team:setData("in-base", false)
    team:setData("carrier", player)
        
    -- Assign flag to player
    FlagPlayer[player] = team
    
    -- Dispatch event
    -- if next(LoadedClient) then
    --     triggerEvent("CTF:onPlayerFlagPickup", player, team)
    -- end
    
    return true
end

function moveTeamFlagToBase(team)
    -- Get the team's flag
    local flag = team:getData("flag")
    
    if not flag then
        return false
    end
    
    -- Get the flag carrier
    local player = team:getData("carrier")
    
    if FlagPlayer[player] then
        FlagPlayer[player] = nil
    end
    
    -- Update team data
    team:setData("in-base", true)
    team:setData("carrier", false)
    
    -- Move flag to base
    flag:detach()
    flag:setPosition(team.position)
    flag:setCollisionsEnabled(false)
    flag:setFrozen(true)
    
    -- Reset flag size
    flag:setScale(8)
    
    -- Dispatch event
    -- if next(LoadedClient) then
    --     triggerEvent("CTF:onTeamFlagRecovery", team, player)
    -- end
    
    -- TODO: Handle players with flags standing in the base colshape
    
    return true
end

function dropTeamFlag(player)
    -- TODO: Check if a player holds his team flag and if we can teleport the flag to its base

    -- Check if player holds any flag
    local team = FlagPlayer[player]
    FlagPlayer[player] = nil
    
    if not isElement(team) then
        return
    end
    
    -- Get the team's flag
    local flag = team:getData("flag")
    
    if not flag then
        return
    end
    
    -- Dispatch event
    triggerEvent("CTF:onTeamFlagDrop", team, LoadedClient[player] and player or false)
    
    -- Get the player's vehicle
    local vehicle = callResourceFunction("race", "getPlayerVehicle", player)
    local onGround = vehicle and vehicle:isOnGround() or false
    
    if not LoadedClient[player] or not onGround then
        -- Teleport flag to base
        moveTeamFlagToBase(team)
    else 
        -- Detach flag from carrier
        flag:detach()
        
        -- Move the flag down
        local position = flag.position + Vector3(0, 0, team:getData("z-offset")) 
        flag.position = position
        
        -- Update the flag
        flag:setScale(8)
        flag:setFrozen(true)
        flag:setCollisionsEnabled(false)
        
        -- Update team data
        team:setData("carrier", false)
        
        -- Create the rescue marker
        createTeamFlagRescueMarker(team)
    end
end
