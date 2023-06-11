ESX = exports["es_extended"]:getSharedObject()

useWaypoint = false -- if you want to use waypoint to player, set this to true and uncomment line 48-50

PlayerData = {}
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

function OpenPlayerListMenu()
    ESX.TriggerServerCallback('getJobPlayers', function(players)
        local elements = {}
        for i = 1, #players, 1 do
            table.insert(elements, {
                label = players[i].name,
                value = players[i].source,
                jobGrade = players[i].jobGrade,
                phoneNumber = players[i].phoneNumber,
                coords = players[i].coords
            })
        end
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_list', {
            title = ESX.PlayerData.job.label,
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            local playerInfo = data.current
            if playerInfo then
                OpenPlayerInfoMenu(playerInfo)
            end
        end, function(data, menu)
            menuOpen = false
            menu.close()
        end)
        menuOpen = true
    end)
end

function OpenPlayerInfoMenu(playerInfo)
	 local elements = {
        {label = 'Rank: ' .. playerInfo.jobGrade},
        {label = 'Phone number: ' .. playerInfo.phoneNumber, phoneNumber = playerInfo.phoneNumber}--[[,
        {label = 'Set waypoint', coords = playerInfo.coords},
		{label = 'Remove waypoint'}]]
    }
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_info', {
        title = playerInfo.label,
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        local phoneNumber = data.current.phoneNumber
        local coords = data.current.coords
        if phoneNumber then
            SetClipboard(phoneNumber)
			ESX.ShowNotification('Phone number of '..playerInfo.label..' has been copied to clipboard')
        end
		if data.current.label == 'Remove waypoint' then
			if DoesBlipExist(waypointBlip) then
				RemoveWaypoint()
				ESX.ShowNotification('Waypoint removed')
			else
				ESX.ShowNotification('No waypoint set')
			end
        end
        if coords then
            SetWaypoint(coords)
			ESX.ShowNotification('Waypoint to '..playerInfo.label..' has been set')
        end
    end, function(data, menu)
        menuOpen = false
        menu.close()
    end)
end

RegisterCommand('menu', function()
	ESX.TriggerServerCallback('hasJob', function(cb)
		if ESX.PlayerData.job.name ~= 'unemployed' then
			OpenPlayerListMenu()
		else
			ESX.ShowNotification('You need to have a job in order to open this menu')
		end
	end)
end)
RegisterKeyMapping('menu', 'Jobmenu', 'keyboard', 'F4')

function SetClipboard(text)
    SendNUIMessage({
        type = 'clipboard',
        data = text
    })
end

function SetWaypoint(coords)
    waypointBlip = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypointBlip) then
        RemoveBlip(waypointBlip) 
    end
    waypointBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(waypointBlip, 8)
    SetBlipColour(waypointBlip, 3) 
    SetBlipRoute(waypointBlip, true) 
    SetBlipRouteColour(waypointBlip, 3) 
end

if useWaypoint then
	Citizen.CreateThread(function()
	local wait = 5000
		while true do
			Wait(wait)
			if DoesBlipExist(waypointBlip) then
				wait = 1000
				local playerPed = PlayerPedId()
				local playerCoords = GetEntityCoords(playerPed)
				if waypointBlip ~= nil then
					local waypointCoords = GetBlipCoords(waypointBlip)
					local distance = #(playerCoords - waypointCoords)
					if distance < 5.0 then
						RemoveWaypoint()
					end
				end
			end
		end
	end)
end

function RemoveWaypoint()
    RemoveBlip(waypointBlip)
    waypointBlip = nil
end

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end
	RemoveWaypoint()
	ESX.UI.Menu.CloseAll()
end)
