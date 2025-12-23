RegisterServerEvent('json:dataStructure')
AddEventHandler('json:dataStructure', function(data)
end)

RegisterServerEvent('qb-radialmenu:trunk:server:Door')
AddEventHandler('qb-radialmenu:trunk:server:Door', function(open, plate, door)
    TriggerClientEvent('qb-radialmenu:trunk:client:Door', -1, plate, door, open)
end)

local function hasDiscordRole(source, roles)
    if roles == nil then return false end
    local resourceState = GetResourceState('discord_perms')
    if resourceState == 'started' then
        for _, roleId in ipairs(roles) do
            local ok, result = pcall(function()
                return exports.discord_perms:IsRolePresent(source, roleId)
            end)
            if ok and result then
                return true
            end
        end
    end

    resourceState = GetResourceState('Badger_Discord_API')
    if resourceState == 'started' then
        for _, roleId in ipairs(roles) do
            local ok, result = pcall(function()
                return exports.Badger_Discord_API:IsDiscordAceAllowed(source, roleId)
            end)
            if ok and result then
                return true
            end
        end
    end

    return false
end

local function buildPlayerRoles(source)
    local allowedRoles = {}
    for role, data in pairs(Config.PermissionGroups) do
        local aceAllowed = data.ace and data.ace ~= '' and IsPlayerAceAllowed(source, data.ace)
        local discordAllowed = hasDiscordRole(source, data.discordRoles)
        if aceAllowed or discordAllowed then
            allowedRoles[#allowedRoles + 1] = role
        end
    end
    for _, role in ipairs(Config.DefaultRoles or {}) do
        allowedRoles[#allowedRoles + 1] = role
    end
    return allowedRoles
end

RegisterNetEvent('qb-radialmenu:server:requestPermissions', function(requestId)
    local src = source
    if type(requestId) ~= 'number' then return end
    local roles = buildPlayerRoles(src)
    TriggerClientEvent('qb-radialmenu:client:setPermissions', src, requestId, roles)
end)
