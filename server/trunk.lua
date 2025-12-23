local trunkBusy = {}

RegisterServerEvent('qb-trunk:server:setTrunkBusy')
AddEventHandler('qb-trunk:server:setTrunkBusy', function(plate, busy)
    if busy then
        trunkBusy[plate] = true
    else
        trunkBusy[plate] = nil
    end
end)

RegisterNetEvent('qb-trunk:server:requestTrunkBusy', function(plate, requestId)
    local src = source
    if type(requestId) ~= 'number' then return end
    local isBusy = trunkBusy[plate] == true
    TriggerClientEvent('qb-trunk:client:receiveTrunkBusy', src, requestId, isBusy)
end)

RegisterServerEvent('qb-trunk:server:KidnapTrunk')
AddEventHandler('qb-trunk:server:KidnapTrunk', function(targetId, closestVehicle)
    TriggerClientEvent('qb-trunk:client:KidnapGetIn', targetId, closestVehicle)
end)

--QBCore.Commands.Add("getintrunk", "Get In Trunk", {}, false, function(source, args)
RegisterCommand("getintrunk", function(source, args, rawCommand)    
    TriggerClientEvent('qb-trunk:client:GetIn', source)
end)

RegisterCommand("putintrunk", function(source, args, rawCommand) 
    TriggerClientEvent('qb-trunk:server:KidnapTrunk', source)
end)
