PoliceJobs = {}

-- Convert config table to usable keys
for i = 1, #Config.PoliceJobNames do
	PoliceJobs[Config.PoliceJobNames[i]] = true
end

if IsDuplicityVersion() then
	Framework.qb = {}

	function Framework.qb.Notify(src, message, type)
		type = type == "info" and "primary" or type
		TriggerClientEvent("QBCore:Notify", src, message, type)
	end

	function Framework.qb.RegisterInventory(stash, label, stashConfig)
		-- Used for ox_inventory compat
	end

	return
end

local function hasApartment(apts)
	for propertyId, _ in pairs(apts) do
		local property = PropertiesTable[propertyId]
		if property.owner then
			return true
		end
	end

	return false
end

Framework.qb = {

	Notify = function(message, type)
		type = type == "info" and "primary" or type
		TriggerEvent("QBCore:Notify", message, type)
	end,

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
					canInteract = function()
						local PlayerData = QBCore.Functions.GetPlayerData()
						local job = PlayerData.job
						local jobName = job.name
						local onDuty = job.onduty
						return jobName == "realtor" and onDuty
					end,
				},
				{
					label = "Property Info",
					icon = "fas fa-circle-info",
					action = showData,
					canInteract = function()
						local PlayerData = QBCore.Functions.GetPlayerData()
						local job = PlayerData.job
						local jobName = job.name
						local onDuty = job.onduty
						return jobName == "realtor" and onDuty
					end,
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
					canInteract = function()
						local PlayerData = QBCore.Functions.GetPlayerData()
						local job = PlayerData.job
						local jobName = job.name
						local gradeAllowed = tonumber(job.grade.level) >= Config.MinGradeToRaid
						local onDuty = job.onduty

						return PoliceJobs[jobName] and gradeAllowed and onDuty
					end,
				},
			},
		})

		return targetName
	end,

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
					canInteract = function()
						local PlayerData = QBCore.Functions.GetPlayerData()
						local job = PlayerData.job
						local jobName = job.name
						local gradeAllowed = tonumber(job.grade.level) >= Config.MinGradeToRaid
						local onDuty = job.onduty

						return jobName == PoliceJobs[jobName] and gradeAllowed and onDuty
					end,
				},
			},
		})
	end,

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
	end,

	RemoveTargetZone = function(targetName)
		exports["qb-target"]:RemoveZone(targetName)
	end,

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
	end,

	RemoveRadialOption = function(id)
		exports["qb-radialmenu"]:RemoveOption(id)
	end,

	AddTargetEntity = function(entity, label, action)
		exports["qb-target"]:AddTargetEntity(entity, {
			options = {
				{
					label = label,
					action = action,
				},
			},
		})
	end,

	RemoveTargetEntity = function(entity)
		exports["qb-target"]:RemoveTargetEntity(entity)
	end,

	OpenInventory = function(stash, stashConfig)
		TriggerServerEvent("inventory:server:OpenInventory", "stash", stash, stashConfig)
		TriggerEvent("inventory:client:SetCurrentStash", stash)
	end,
}