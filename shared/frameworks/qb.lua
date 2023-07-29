if not GetResourceState("qb_core"):find("start") then return end

QBCore = exports["qb-core"]:GetCoreObject()

if IsDuplicityVersion() then
	function Framework.Notify(src, message, type)
		type = type == "info" and "primary" or type
		TriggerClientEvent("QBCore:Notify", src, message, type)
	end

	function Framework.RegisterInventory(stash, label, stashConfig)
		-- Used for ox_inventory compat
	end

	function Framework.getPlayerData(source)
		local player = QBCore.Functions.GetPlayer(source)
		if not player then return end

		return player.PlayerData
	end

	function Framework.getIdentifier(source)
		local player = Framework.getPlayerData(source)
		if not player then return end

		return player.citizenid
	end

	function Framework.getName(source)
		local player = Framework.getPlayerData(source)
		if not player then return end

		return ("%s %s"):format(player.charinfo.firstname, player.charinfo.lastname)
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
	Notify = function(message, type)
		type = type == "info" and "primary" or type
		TriggerEvent("QBCore:Notify", message, type)
	end

	AddEntrance = function(coords, size, heading, propertyId, enter, raid, showcase, showData, targetName)
		local property_id = propertyId
		exports["qb-target"]:AddBoxZone(targetName, vector3(coords.x, coords.y, coords.z), size.x, size.y, {
			name = targetName,
			heading = heading,
			debugPoly = Config.DebugMode,
			minZ = coords.z - 1.5,
			maxZ = coords.z + 2.0,
		}, {
			options = {
				{
					label = "Enter Property",
					icon = "fas fa-door-open",
					action = enter,
					canInteract = function()
						local property = Property.Get(property_id)
						return property.has_access or property.owner
					end,
				},
				{
					label = "Showcase Property",
					icon = "fas fa-eye",
					action = showcase,
					groups = RealtorGroup,
				},
				{
					label = "Property Info",
					icon = "fas fa-circle-info",
					action = showData,
					groups = RealtorGroup,
				},
				{
					label = "Ring Doorbell",
					icon = "fas fa-bell",
					action = enter,
					canInteract = function()
						local property = Property.Get(property_id)
						return not property.has_access and not property.owner
					end,
				},
				{
					label = "Raid Property",
					icon = "fas fa-building-shield",
					action = raid,
					groups = PoliceGroup,
				},
			},
		})

		return targetName
	end

	AddApartmentEntrance = function(coords, size, heading, apartment, enter, seeAll, seeAllToRaid, targetName)
		exports["qb-target"]:AddBoxZone(targetName, vector3(coords.x, coords.y, coords.z), size.x, size.y, {
			name = targetName,
			heading = heading,
			debugPoly = Config.DebugMode,
			minZ = coords.z - 1.0,
			maxZ = coords.z + 2.0,
		}, {
			options = {
				{
					label = "Enter Apartment",
					action = enter,
					icon = "fas fa-door-open",
					canInteract = function()
						local apartments = ApartmentsTable[apartment].apartments
						return hasApartment(apartments)
					end,
				},
				{
					label = "See all apartments",
					icon = "fas fa-circle-info",
					action = seeAll,
				},
				{
					label = "Raid Apartment",
					action = seeAllToRaid,
					icon = "fas fa-building-shield",
					groups = PoliceGroup,
				},
			},
		})
	end

	AddDoorZoneInside = function(coords, size, heading, leave, checkDoor)
		exports["qb-target"]:AddBoxZone("shellExit", vector3(coords.x, coords.y, coords.z), size.x, size.y, {
			name = "shellExit",
			heading = heading,
			debugPoly = Config.DebugMode,
			minZ = coords.z - 2.0,
			maxZ = coords.z + 1.0,
		}, {
			options = {
				{
					label = "Leave Property",
					action = leave,
					icon = "fas fa-right-from-bracket",
				},
				{
					label = "Check Door",
					action = checkDoor,
					icon = "fas fa-bell",
				},
			},
		})

		return "shellExit"
	end

	RemoveTargetZone = function(targetName)
		exports["qb-target"]:RemoveZone(targetName)
	end

	AddRadialOption = function(id, label, icon, _, event, options)
		exports["qb-radialmenu"]:AddOption({
			id = id,
			title = label,
			icon = icon,
			type = "client",
			event = event,
			shouldClose = true,
			options = options,
		}, id)
	end

	RemoveRadialOption = function(id)
		exports["qb-radialmenu"]:RemoveOption(id)
	end

	AddTargetEntity = function(entity, label, icon, action)
		exports["qb-target"]:AddTargetEntity(entity, {
			options = {
				{
					label = label,
					icon = icon,
					action = action,
				},
			},
		})
	end

	RemoveTargetEntity = function(entity)
		exports["qb-target"]:RemoveTargetEntity(entity)
	end

	OpenInventory = function(stash, stashConfig)
		TriggerServerEvent("inventory:server:OpenInventory", "stash", stash, stashConfig)
		TriggerEvent("inventory:client:SetCurrentStash", stash)
	end
end