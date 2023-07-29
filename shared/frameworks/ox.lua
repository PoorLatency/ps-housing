if not GetResourceState("ox_core"):find("start") then return end

local file = ("imports/%s.lua"):format(IsDuplicityVersion() and "server" or "client")
local import = LoadResourceFile("ox_core", file)
local chunk = assert(load(import, ("@@ox_core/%s"):format(file)))
chunk()

if IsDuplicityVersion() then
	function Framework.Notify(source, message, type)
		type = type == "inform" and "info" or type
		TriggerClientEvent("ox_lib:notify", source, { title = "Property", description = message, type = type })
	end

	function Framework.RegisterInventory(stash, label, stashConfig)
		exports.ox_inventory:RegisterStash(stash, label, stashConfig.slots, stashConfig.maxweight, nil)
	end

	function Framework.getPlayerData(source)
		local player = Ox.GetPlayer(source)
		if not player then return end

		return player
	end

	function Framework.getIdentifier(source)
		local player = Framework.getPlayerData(source)
		if not player then return end

		return player.charid
	end

	function Framework.getName(source)
		local player = Framework.getPlayerData(source)
		if not player then return end

		return ("%s %s"):format(player.firstname, player.lastname)
	end

	function Framework.getBalance(source)
		local player = Framework.getPlayerData(source)
		if not player then return end
	end

	function Framework.addMoney(source, amount)
		local player = Framework.getPlayerData(source)
		if not player then return end
	end

	function Framework.removeMoney(source, amount)
		local player = Framework.getPlayerData(source)
		if not player then return end
	end
else
	Notify = function(message, type)
		type = type == "inform" and "info" or type

		lib.notify({
			title = "Property",
			description = message,
			type = type,
		})
	end

	AddEntrance = function(coords, size, heading, propertyId, enter, raid, showcase, showData, _)
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

	AddApartmentEntrance = function(coords, size, heading, apartment, enter, seeAll, seeAllToRaid, _)
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
			},
		})

		return handler
	end

	AddDoorZoneInside = function(coords, size, heading, leave, checkDoor)
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

	RemoveTargetZone = function(handler)
		exports.ox_target:removeZone(handler)
	end

	AddRadialOption = function(id, label, icon, fn)
		lib.addRadialItem({
			id = id,
			icon = icon,
			label = label,
			onSelect = fn,
		})
	end

	RemoveRadialOption = function(id)
		lib.removeRadialItem(id)
	end

	AddTargetEntity = function(entity, label, icon, action)
		exports.ox_target:addLocalEntity(entity, {
			{
				name = label,
				label = label,
				icon = icon,
				onSelect = action,
			},
		})
	end

	RemoveTargetEntity = function(entity)
		exports.ox_target:removeLocalEntity(entity)
	end

	OpenInventory = function(stash, stashConfig)
		exports.ox_inventory:openInventory("stash", stash)
	end
end