ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('getJobPlayers', function(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return
    end
    local jobPlayers = {}
    local players = GetPlayers()
    for i = 1, #players do
        local target = ESX.GetPlayerFromId(players[i])
        if target and target.job.name == xPlayer.job.name then
            local jobGrade = target.job.grade_label or ''
            local phoneNumber = GetPlayerPhoneNumber(target.identifier)
			local playerCoords = target.getCoords(true)
            table.insert(jobPlayers, {
                source = target.source,
                name = target.name,
                jobGrade = jobGrade,
                phoneNumber = phoneNumber,
                coords = playerCoords
            })
        end
    end
    callback(jobPlayers)
end)

function GetPlayerPhoneNumber(identifier)
    local result = MySQL.scalar.await("SELECT `phone_number` FROM `users` WHERE `identifier` = @identifier", {['@identifier'] = identifier})
    return result or ''
end

ESX.RegisterServerCallback('hasJob', function(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return
    end
    local xJob = xPlayer.getJob().name
	if xJob ~= 'unemployed' then
		callback(true)
	end
    callback(false)
end)
