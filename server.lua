local RSGCore = exports['rsg-core']:GetCoreObject()
local carriedEntities = {}

-- Event to sync entity carry status
RegisterServerEvent('redm:syncEntityCarry')
AddEventHandler('redm:syncEntityCarry', function(netId, carrying)
    local src = source
    if carrying then
        carriedEntities[netId] = src
        TriggerClientEvent('redm:updateEntityCarry', -1, netId, true, src)
    else
        carriedEntities[netId] = nil
        TriggerClientEvent('redm:updateEntityCarry', -1, netId, false, src)
    end
end)

-- Function to handle entity drop logic
local function handleEntityDrop(src)
    for netId, player in pairs(carriedEntities) do
        if player == src then
            carriedEntities[netId] = nil
            TriggerClientEvent('redm:updateEntityCarry', -1, netId, false, src)
        end
    end
end

-- Clean up if a player disconnects while carrying an object
AddEventHandler('playerDropped', function(reason)
    local src = source
    handleEntityDrop(src)
end)

-- Command to force drop all carried objects (for admin use)
RSGCore.Commands.Add('forcedropall', 'Force all players to drop carried objects', {}, false, function(source, args)
    for netId, player in pairs(carriedEntities) do
        carriedEntities[netId] = nil
        TriggerClientEvent('redm:updateEntityCarry', -1, netId, false, player)
    end
    TriggerClientEvent('RSGCore:Notify', source, 'All carried objects have been forcibly dropped', 'success')
end, 'admin')

-- Optional: Command to force drop carried objects for a specific player (for admin use)
RSGCore.Commands.Add('forcedrop', 'Force a specific player to drop carried objects', {{name = 'playerId', help = 'ID of the player'}}, true, function(source, args)
    local playerId = tonumber(args[1])
    if playerId then
        handleEntityDrop(playerId)
        TriggerClientEvent('RSGCore:Notify', source, 'Player ' .. playerId .. ' has dropped all carried objects', 'success')
    else
        TriggerClientEvent('RSGCore:Notify', source, 'Invalid player ID', 'error')
    end
end, 'admin')

