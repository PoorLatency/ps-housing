if not GetResourceState("es_extended"):find("start") then return end

ESX = exports["es_extended"]:getSharedObject()

if IsDuplicityVersion() then
	function Framework.Notify(source, message, type)
		if Config.Notify == "ox" then
			type = type == "inform" and "info" or type
			TriggerClientEvent("ox_lib:notify", source, { title = "Property", description = message, type = type })
		else
			-- Custom notify support here.
		end
	end

	function Framework.RegisterInventory(stash, label, stashConfig)
		if GetResourceState("ox_inventory"):find("start") and Config.Inventory == "ox" then
			exports.ox_inventory:RegisterStash(stash, label, stashConfig.slots, stashConfig.maxweight, nil)
		else
			-- Custom inventory support here.
		end
	end

	function Framework.getPlayerData(source)
		local player = ESX.GetPlayerFromId(source)
		if not player then return end

		return player
	end

	function Framework.getIdentifier(source)
		local player = Framework.getPlayerData(source)
		if not player then return end

		return player.identifier
	end

	function Framework.getName(source)
		local player = Framework.getPlayerData(source)
		if not player then return end

		return player.getName()
	end

	function Framework.getBalance(source)
		local player = Framework.getPlayerData(source)
		if not player then return end

		local money = player.getMoney()
		local bank = player.getAccount("bank").money

		if money < 0 then return bank end

		return money
	end

	function Framework.addMoney(source, amount)
		local player = Framework.getPlayerData(source)
		if not player then return end

		return player.addMoney(amount)
	end

	function Framework.removeMoney(source, amount)
		local player = Framework.getPlayerData(source)
		if not player then return end

		return player.removeMoney(amount)
	end
else
	function Framework.getPlayerData()
		return ESX.PlayerData()
	end

	function Framework.getPlayerIdentifier()
		return ESX.PlayerData.identifier
	end

	function Notify(message, type)
		type = type == "inform" and "info" or type

		lib.notify({
			title = "Property",
			description = message,
			type = type,
		})
	end

	function AddEntrance(coords, size, heading, propertyId, enter, raid, showcase, showData, _)
		local property_id = propertyId

		local handler = exports.ox_target:addBoxZone({
			coords = vector3(coords.x, coords.y, coords.z),
			size = vector3(size.y, size.x, size.z),
			rotation = heading,
			debug = Config.DebugMode,
			options = {
				{
					label = "Enter Property",
					icon = "fas fa-door-open",
					onSelect = enter,
					canInteract = function()
						local property = Property.Get(property_id)
						return property.has_access or property.owner
					end,
				},
				{
					label = "Showcase Property",
					icon = "fas fa-eye",
					onSelect = showcase,
					groups = RealtorGroup,
				},
				{
					label = "Property Info",
					icon = "fas fa-circle-info",
					onSelect = showData,
					groups = RealtorGroup,
				},
				{
					label = "Ring Doorbell",
					icon = "fas fa-bell",
					onSelect = enter,
					canInteract = function()
						local property = Property.Get(property_id)
						return not property.has_access and not property.owner
					end,
				},
				{
					label = "Raid Property",
					icon = "fas fa-building-shield",
					onSelect = raid,
					groups = PoliceGroup,
				},
			},
		})

		return handler
	end

	function AddApartmentEntrance(coords, size, heading, apartment, enter, seeAll, seeAllToRaid, _)
		local handler = exports.ox_target:addBoxZone({
			coords = vector3(coords.x, coords.y, coords.z),
			size = vector3(size.y, size.x, size.z),
			rotation = heading,
			debug = Config.DebugMode,
			options = {
				{
					label = "Enter Apartment",
					onSelect = enter,
					icon = "fas fa-door-open",
					canInteract = function()
						local apartments = ApartmentsTable[apartment].apartments
						return hasApartment(apartments)
					end,
				},
				{
					label = "See all apartments",
					onSelect = seeAll,
					icon = "fas fa-circle-info",
				},
				{
					label = "Raid Apartment",
					onSelect = seeAllToRaid,
					icon = "fas fa-building-shield",
					groups = PoliceGroup,
			},
		})

		return handler
	end

	function AddDoorZoneInside(coords, size, heading, leave, checkDoor)
		local handler = exports.ox_target:addBoxZone({
			coords = vector3(coords.x, coords.y, coords.z), --z = 3.0
			size = vector3(size.y, size.x, size.z),
			rotation = heading,
			debug = Config.DebugMode,
			options = {
				{
					name = "leave",
					label = "Leave Property",
					onSelect = leave,
					icon = "fas fa-right-from-bracket",
				},
				{
					name = "doorbell",
					label = "Check Door",
					onSelect = checkDoor,
					icon = "fas fa-bell",
				},
			},
		})

		return handler
	end

	function RemoveTargetZone(handler)
		exports.ox_target:removeZone(handler)
	end

	function AddRadialOption(id, label, icon, fn)
		lib.addRadialItem({
			id = id,
			icon = icon,
			label = label,
			onSelect = fn,
		})
	end

	function RemoveRadialOption(id)
		lib.removeRadialItem(id)
	end

	function AddTargetEntity(entity, label, icon, action)
		exports.ox_target:addLocalEntity(entity, {
			{
				name = label,
				label = label,
				icon = icon,
				onSelect = action,
			},
		})
	end

	function RemoveTargetEntity(entity)
		exports.ox_target:removeLocalEntity(entity)
	end

	function OpenInventory(stash, stashConfig)
		exports.ox_inventory:openInventory("stash", stash)
	end

	RegisterNetEvent("esx:playerLoaded")
	AddEventHandler("esx:playerLoaded", function(player)
		ESX.PlayerData = player
		ESX.PlayerLoaded = true
		InitialiseProperties()
	end)

	RegisterNetEvent("esx:onPlayerLogout")
	AddEventHandler("esx:onPlayerLogout", function()
		ESX.PlayerLoaded = false
	end)
end