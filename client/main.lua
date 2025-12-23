local inRadialMenu = false
local IsDown = false
local playerRoles = {}
local permissionRequestId = 0
local permissionCallbacks = {}

local function tableContains(tbl, value)
    for _, item in ipairs(tbl) do
        if item == value then
            return true
        end
    end
    return false
end

local function mergeRoles()
    local roles = {}
    for _, role in ipairs(Config.DefaultRoles) do
        if not tableContains(roles, role) then
            roles[#roles + 1] = role
        end
    end
    for _, role in ipairs(playerRoles) do
        if not tableContains(roles, role) then
            roles[#roles + 1] = role
        end
    end
    return roles
end

local function hasRole(role)
    return tableContains(playerRoles, role) or tableContains(Config.DefaultRoles, role)
end

local function requestPermissions(cb)
    permissionRequestId = permissionRequestId + 1
    if cb then
        permissionCallbacks[permissionRequestId] = cb
    end
    TriggerServerEvent('qb-radialmenu:server:requestPermissions', permissionRequestId)
end

local function getClosestVehicle(radius)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, radius or 10.0, 0, 70)
    if vehicle == 0 then
        return nil
    end
    return vehicle
end

local function getClosestPlayer()
    local players = GetActivePlayers()
    local closestPlayer = -1
    local closestDistance = -1
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    for _, player in ipairs(players) do
        local target = GetPlayerPed(player)
        if target ~= ped then
            local targetCoords = GetEntityCoords(target)
            local distance = #(coords - targetCoords)
            if closestDistance == -1 or distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

RegisterNetEvent('qb-radialmenu:client:setPermissions', function(requestId, roles)
    playerRoles = roles or {}
    if permissionCallbacks[requestId] then
        permissionCallbacks[requestId]()
        permissionCallbacks[requestId] = nil
    end
end)

Citizen.CreateThread(function()
    requestPermissions()
end)

RegisterNetEvent('esx_ambulancejob:revive', function(pw)
    IsDown = false
end)

AddEventHandler('playerSpawned', function()
    IsDown = false
end)

AddEventHandler('baseevents:onPlayerDied', function()
    IsDown = true
end)

AddEventHandler('baseevents:onPlayerKilled', function()
    IsDown = true
end)

RegisterCommand('_rad', function()
    if not IsPauseMenuActive() and not inRadialMenu then
        local opened = false
        requestPermissions(function()
            if opened then return end
            openRadial(true)
            SetCursorLocation(0.5, 0.5)
            opened = true
        end)

        SetTimeout(250, function()
            if not opened then
                openRadial(true)
                SetCursorLocation(0.5, 0.5)
                opened = true
            end
        end)
    end
end)

RegisterKeyMapping('_rad', 'Open Radial Menu', 'keyboard', 'M')

local ofcDownAdded = false

function setupSubItems()
    local roles = mergeRoles()

    if (IsDown and hasRole("police")) then
        if not ofcDownAdded then
            temptable = {
                id = 'officerdown',
                title = '10-999',
                icon = 'sad-cry',
                type = 'client',
                event = 'pb-police:ofcdown',
                shouldClose = true,
            }
            table.insert(Config.MenuItems, temptable)
            ofcDownAdded = true
        end
        -- print('ofc down')
    else
        if ofcDownAdded then
            for k,v in pairs(Config.MenuItems) do
                if v.id == 'officerdown' then
                    table.remove(Config.MenuItems, k)
                    ofcDownAdded = false
                    break
                end
            end
        end
        -- print('not down or police')
    end

    local mergedInteractions = {}
    for _, role in ipairs(roles) do
        if Config.RoleInteractions[role] ~= nil and next(Config.RoleInteractions[role]) ~= nil then
            for _, item in ipairs(Config.RoleInteractions[role]) do
                mergedInteractions[#mergedInteractions + 1] = item
            end
        end
    end
    Config.MenuItems[4].items = mergedInteractions

    local Vehicle = GetVehiclePedIsIn(PlayerPedId())

    if Vehicle ~= nil or Vehicle ~= 0 then
        local AmountOfSeats = GetVehicleModelNumberOfSeats(GetEntityModel(Vehicle))

        if AmountOfSeats == 2 then
            Config.MenuItems[3].items[2].items = {
                [1] = {
                    id    = -1,
                    title = 'Driver',
                    icon = 'caret-up',
                    type = 'client',
                    event = 'qb-radialmenu:client:ChangeSeat',
                    shouldClose = false,
                },
                [2] = {
                    id    = 0,
                    title = 'Passenger',
                    icon = 'caret-up',
                    type = 'client',
                    event = 'qb-radialmenu:client:ChangeSeat',
                    shouldClose = false,
                },
            }
        elseif AmountOfSeats == 3 then
            Config.MenuItems[3].items[2].items = {
                [4] = {
                    id    = -1,
                    title = 'Driver',
                    icon = 'caret-up',
                    type = 'client',
                    event = 'qb-radialmenu:client:ChangeSeat',
                    shouldClose = false,
                },
                [1] = {
                    id    = 0,
                    title = 'Passenger',
                    icon = 'caret-up',
                    type = 'client',
                    event = 'qb-radialmenu:client:ChangeSeat',
                    shouldClose = false,
                },
                [3] = {
                    id    = 1,
                    title = 'Other',
                    icon = 'caret-down',
                    type = 'client',
                    event = 'qb-radialmenu:client:ChangeSeat',
                    shouldClose = false,
                },
            }
        elseif AmountOfSeats == 4 then
            Config.MenuItems[3].items[2].items = {
                [4] = {
                    id    = -1,
                    title = 'Driver',
                    icon = 'caret-up',
                    type = 'client',
                    event = 'qb-radialmenu:client:ChangeSeat',
                    shouldClose = false,
                },
                [1] = {
                    id    = 0,
                    title = 'Passenger',
                    icon = 'caret-up',
                    type = 'client',
                    event = 'qb-radialmenu:client:ChangeSeat',
                    shouldClose = false,
                },
                [3] = {
                    id    = 1,
                    title = 'Rear Left',
                    icon = 'caret-down',
                    type = 'client',
                    event = 'qb-radialmenu:client:ChangeSeat',
                    shouldClose = false,
                },
                [2] = {
                    id    = 2,
                    title = 'Rear Right',
                    icon = 'caret-down',
                    type = 'client',
                    event = 'qb-radialmenu:client:ChangeSeat',
                    shouldClose = false,
                },
            }
        end
    end
end

function openRadial(bool)    
    setupSubItems()

    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "ui",
        radial = bool,
        items = Config.MenuItems
    })
    inRadialMenu = bool
end

function closeRadial(bool)    
    SetNuiFocus(false, false)
    inRadialMenu = bool
end

RegisterNUICallback('closeRadial', function()
    closeRadial(false)
end)

RegisterNUICallback('selectItem', function(data)
    local itemData = data.itemData

    if itemData.type == 'client' then
        TriggerEvent(itemData.event, itemData)
    elseif itemData.type == 'server' then
        TriggerServerEvent(itemData.event, itemData)
    elseif itemData.type == 'cmd' then
        ExecuteCommand(itemData.event)
    end
end)

RegisterNetEvent('qb-radialmenu:client:noPlayers')
AddEventHandler('qb-radialmenu:client:noPlayers', function(data)
    --QBCore.Functions.Notify('There arrent any people close', 'error', 2500)
    exports['mythic_notify']:SendAlert('inform', 'There arrent any people close')
end)

RegisterNetEvent('qb-radialmenu:client:giveidkaart')
AddEventHandler('qb-radialmenu:client:giveidkaart', function(data)
    -- ??
end)

RegisterNetEvent('qb-radialmenu:client:openDoor')
AddEventHandler('qb-radialmenu:client:openDoor', function(data)
    local string = data.id
    local replace = string:gsub("door", "")
    local door = tonumber(replace)
    local ped = PlayerPedId()
    local closestVehicle = nil

    if IsPedInAnyVehicle(ped, false) then
        closestVehicle = GetVehiclePedIsIn(ped)
    else
        closestVehicle = getClosestVehicle()
    end

    if closestVehicle ~= nil and closestVehicle ~= 0 then
        if closestVehicle ~= GetVehiclePedIsIn(ped) then
            local plate = GetVehicleNumberPlateText(closestVehicle)
            if GetVehicleDoorAngleRatio(closestVehicle, door) > 0.0 then
                if not IsVehicleSeatFree(closestVehicle, -1) then
                    TriggerServerEvent('qb-radialmenu:trunk:server:Door', false, plate, door)
                else
                    SetVehicleDoorShut(closestVehicle, door, false)
                end
            else
                if not IsVehicleSeatFree(closestVehicle, -1) then
                    TriggerServerEvent('qb-radialmenu:trunk:server:Door', true, plate, door)
                else
                    SetVehicleDoorOpen(closestVehicle, door, false, false)
                end
            end
        else
            if GetVehicleDoorAngleRatio(closestVehicle, door) > 0.0 then
                SetVehicleDoorShut(closestVehicle, door, false)
            else
                SetVehicleDoorOpen(closestVehicle, door, false, false)
            end
        end
    else
        --QBCore.Functions.Notify('There is no vehicle in sight...', 'error', 2500)
        exports['mythic_notify']:SendAlert('error', 'There is no vehicle in sight...')
    end
end)

RegisterNetEvent('qb-radialmenu:client:setExtra')
AddEventHandler('qb-radialmenu:client:setExtra', function(data)
    local string = data.id
    local replace = string:gsub("extra", "")
    local extra = tonumber(replace)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    local enginehealth = 1000.0
    local bodydamage = 1000.0

    if veh ~= nil then
        local plate = GetVehicleNumberPlateText(veh)
    
        if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
            if DoesExtraExist(veh, extra) then 
                if IsVehicleExtraTurnedOn(veh, extra) then
                    enginehealth = GetVehicleEngineHealth(veh)
                    bodydamage = GetVehicleBodyHealth(veh)
                    SetVehicleExtra(veh, extra, 1)
                    SetVehicleEngineHealth(veh, enginehealth)
                    SetVehicleBodyHealth(veh, bodydamage)
                    --QBCore.Functions.Notify('Extra ' .. extra .. ' Deactivated', 'error', 2500)
                    exports['mythic_notify']:SendAlert('error', 'Extra ' .. extra .. ' Deactivated')
                else
                    enginehealth = GetVehicleEngineHealth(veh)
                    bodydamage = GetVehicleBodyHealth(veh)
                    SetVehicleExtra(veh, extra, 0)
                    SetVehicleEngineHealth(veh, enginehealth)
                    SetVehicleBodyHealth(veh, bodydamage)
                    --QBCore.Functions.Notify('Extra ' .. extra .. ' Activated', 'success', 2500)
                    exports['mythic_notify']:SendAlert('success', 'Extra ' .. extra .. ' Activated')
                end    
            else
                --QBCore.Functions.Notify('Extra ' .. extra .. ' Its not pressent on this vehicle ', 'error', 2500)
                exports['mythic_notify']:SendAlert('error', 'Extra ' .. extra .. ' is not possible for this vehicle')
            end
        else
            --QBCore.Functions.Notify('Your not a driver of a vehicle !', 'error', 2500)
            exports['mythic_notify']:SendAlert('error', 'Your not the driver of a vehicle !')
        end
    end
end)

RegisterNetEvent('qb-radialmenu:trunk:client:Door')
AddEventHandler('qb-radialmenu:trunk:client:Door', function(plate, door, open)
    local veh = GetVehiclePedIsIn(PlayerPedId())

    if veh ~= 0 then
        local pl = GetVehicleNumberPlateText(veh)

        if pl == plate then
            if open then
                SetVehicleDoorOpen(veh, door, false, false)
            else
                SetVehicleDoorShut(veh, door, false)
            end
        end
    end
end)

local Seats = {
    ["-1"] = "Driver's Seat",
    ["0"] = "Passenger's Seat",
    ["1"] = "Rear Left Seat",
    ["2"] = "Rear Right Seat",
}

RegisterNetEvent('qb-radialmenu:client:ChangeSeat')
AddEventHandler('qb-radialmenu:client:ChangeSeat', function(data)
    local Veh = GetVehiclePedIsIn(PlayerPedId())
    local IsSeatFree = IsVehicleSeatFree(Veh, data.id)
    local speed = GetEntitySpeed(Veh)
    -- local HasHarnass = exports['qb-smallresources']:HasHarness()
    -- if not HasHarnass then
        local kmh = (speed * 3.6);  

        if IsSeatFree then
            if kmh <= 100.0 then
                SetPedIntoVehicle(PlayerPedId(), Veh, data.id)
                --QBCore.Functions.Notify('Your now on the  '..data.title..'!')
                exports['mythic_notify']:SendAlert('inform', 'Your now on the  '..data.title..'!')
            else
                --QBCore.Functions.Notify('The vehicle goes to fast..')
                exports['mythic_notify']:SendAlert('inform', 'The vehicle goes too fast..')
            end
        else
            --QBCore.Functions.Notify('This seat is occupied..')
            exports['mythic_notify']:SendAlert('inform', 'This seat is occupied..')
        end
    -- else
        --QBCore.Functions.Notify('You have a race harnas on u cant switch..', 'error')
        -- exports['mythic_notify']:SendAlert('error', 'You have a race harnas on u cant switch..')
    -- end
end)

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end
