-- utils.lua

-- Helper function to enumerate entities within a specified distance
function EnumerateEntitiesWithinDistance(entities, coords, maxDistance)
    local nearbyEntities = {}

    if not coords then
        coords = GetEntityCoords(PlayerPedId())
    end

    for _, entity in ipairs(entities) do
        if #(coords - GetEntityCoords(entity)) <= maxDistance then
            table.insert(nearbyEntities, entity)
        end
    end

    return nearbyEntities
end

-- Function to retrieve all objects in the game world
function GetObjects()
    local objects = {}
    local handle, object = FindFirstObject()
    if handle then
        local success
        repeat
            if not IsEntityDead(object) then
                table.insert(objects, object)
            end
            success, object = FindNextObject(handle)
        until not success
        EndFindObject(handle)
    end
    return objects
end

-- Function to retrieve all vehicles in the game world
function GetVehicles()
    local vehicles = {}
    local handle, vehicle = FindFirstVehicle()
    if handle then
        local success
        repeat
            if not IsEntityDead(vehicle) then
                table.insert(vehicles, vehicle)
            end
            success, vehicle = FindNextVehicle(handle)
        until not success
        EndFindVehicle(handle)
    end
    return vehicles
end

-- Function to retrieve all pedestrians in the game world, optionally ignoring the player
function GetPeds(ignorePlayer)
    local peds = {}
    local handle, ped = FindFirstPed()
    if handle then
        local success
        repeat
            if not IsEntityDead(ped) and (not ignorePlayer or ped ~= PlayerPedId()) then
                table.insert(peds, ped)
            end
            success, ped = FindNextPed(handle)
        until not success
        EndFindPed(handle)
    end
    return peds
end

-- Wrapper functions to enumerate entities of specific types within a specified distance
function EnumerateObjectsWithinDistance(coords, maxDistance)
    return EnumerateEntitiesWithinDistance(GetObjects(), coords, maxDistance)
end

function EnumerateVehiclesWithinDistance(coords, maxDistance)
    return EnumerateEntitiesWithinDistance(GetVehicles(), coords, maxDistance)
end

function EnumeratePedsWithinDistance(coords, maxDistance, ignorePlayer)
    return EnumerateEntitiesWithinDistance(GetPeds(ignorePlayer), coords, maxDistance)
end
