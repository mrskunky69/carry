local RSGCore = exports['rsg-core']:GetCoreObject()
local carriedEntities = {}

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

-- Clean up if a player disconnects while carrying an object
AddEventHandler('playerDropped', function(reason)
    local src = source
    for netId, player in pairs(carriedEntities) do
        if player == src then
            carriedEntities[netId] = nil
            TriggerClientEvent('redm:updateEntityCarry', -1, netId, false, src)
        end
    end
end)

-- Command to force drop all carried objects (for admin use)
RSGCore.Commands.Add('forcedropall', 'Force all players to drop carried objects', {}, false, function(source, args)
    for netId, player in pairs(carriedEntities) do
        carriedEntities[netId] = nil
        TriggerClientEvent('redm:updateEntityCarry', -1, netId, false, player)
    end
    TriggerClientEvent('RSGCore:Notify', source, 'All carried objects have been forcibly dropped', 'success')
end, 'admin')
