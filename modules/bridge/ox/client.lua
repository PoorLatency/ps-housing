if GetResourceState("ox_core") ~= "started" then return end

assert(load(LoadResourceFile("ox_core", "imports/client.lua"), "@@ox_core/imports/client.lua"))()

---@param data table Optional data to be passed.
---@return table The player data retrieved.
function Framework.GetPlayerData(data)
	return Ox.GetPlayerData(data)
end

---@param message string
---@param type "error" | "info" | "success"
function Framework.Notify(message, type)
	return lib.notify({
		title = "Property",
		duration = 5000,
		description = message,
		position = "center-right",
		type = type == "inform" and "info" or type,
	})
end

---@param handler any
function Framework.RemoveTargetZone(handler)
	exports.ox_target:removeZone(handler)
end

---@param id string
---@param label string
---@param icon string
---@param fn function
function Framework.AddRadialOption(id, label, icon, fn)
	lib.addRadialItem({
		id = id,
		icon = icon,
		label = label,
		onSelect = fn,
	})
end

---@param id string
function Framework.RemoveRadialOption(id)
	lib.removeRadialItem(id)
end

---@param entity any
---@param label string
---@param action function
function Framework.AddTargetEntity(entity, label, action)
	exports.ox_target:addLocalEntity(entity, {
		{
			name = label,
			label = label,
			onSelect = action,
		},
	})
end

---@param entity any
function Framework.RemoveTargetEntity(entity)
	exports.ox_target:removeLocalEntity(entity)
end

---@param stash string
---@param stashConfig table
---@field slots number
---@field maxweight number
function Framework.OpenInventory(stash, stashConfig)
	exports.ox_inventory:openInventory("stash", stash)
end

---@param coords table
---@field x number
---@field y number
---@field z number
---@param size table
---@field x number
---@field y number
---@field z number
---@param heading number
---@param propertyId string
---@param enter function
---@param raid function
---@param showcase function
---@param showData function
---@param _ any
---@return any
function Framework.AddEntrance(coords, size, heading, propertyId, enter, raid, showcase, showData, _)
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
				canInteract = function()
					-- local property = Property.Get(property_id)
					-- if property.propertyData.owner ~= nil then return false end -- if its owned, it cannot be showcased

					local PlayerData = QBCore.Functions.GetPlayerData() -- GetPlayerData() (?)
					local job = PlayerData.job
					local jobName = job.name

					return jobName == "realtor"
				end,
			},
			{
				label = "Property Info",
				icon = "fas fa-circle-info",
				onSelect = showData,
				canInteract = function()
					local PlayerData = QBCore.Functions.GetPlayerData() -- GetPlayerData() (?)
					local job = PlayerData.job
					local jobName = job.name
					local onDuty = job.onduty
					return jobName == "realtor" and onDuty
				end,
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
				canInteract = function()
					local PlayerData = QBCore.Functions.GetPlayerData() -- GetPlayerData() (?)
					local job = PlayerData.job
					local jobName = job.name
					local gradeAllowed = tonumber(job.grade.level) >= Config.MinGradeToRaid
					local onDuty = job.onduty

					return jobName == "police" and onDuty and gradeAllowed
				end,
			},
		},
	})

	return handler
end

---@param coords table
---@field x number
---@field y number
---@field z number
---@param size table
---@field x number
---@field y number
---@field z number
---@param heading number
---@param apartment string
---@param enter function
---@param seeAll function
---@param seeAllToRaid function
---@param _ any
---@return any
function Framework.AddApartmentEntrance(coords, size, heading, apartment, enter, seeAll, seeAllToRaid, _)
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
				canInteract = function()
					local PlayerData = QBCore.Functions.GetPlayerData() -- GetPlayerData() (?)
					local job = PlayerData.job
					local jobName = job.name
					local gradeAllowed = tonumber(job.grade.level) >= Config.MinGradeToRaid
					local onDuty = job.onduty

					return jobName == "police" and onDuty and gradeAllowed
				end,
			},
		},
	})

	return handler
end

---@param coords table
---@field x number
---@field y number
---@field z number
---@param size table
---@field x number
---@field y number
---@field z number
---@param heading number
---@param leave function
---@param checkDoor function
---@return any
function Framework.AddDoorZoneInside(coords, size, heading, leave, checkDoor)
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