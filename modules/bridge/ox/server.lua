if GetResourceState("ox_core") ~= "started" then return end

assert(load(LoadResourceFile("ox_core", "imports/server.lua"), "@@ox_core/imports/server.lua"))()

---@param source integer
---@return table
function Framework.GetPlayerFromId(source)
	return Ox.GetPlayer(source)
end

---@param identifier integer
---@return table
function Framework.GetPlayerFromIdentifier(identifier)
	return Ox.GetPlayerByFilter({ charid = identifier })
end

---@param player table
---@return integer
function Framework.GetIdentifier(player)
	return player.charid
end

---@param source integer
---@return number
function Framework.GetMoney(source)
	return exports.ox_inventory:GetItem(source, "money", false, true) or 0
end

---@param source integer
---@param amount number
function Framework.RemoveMoney(source, amount)
	exports.ox_inventory:RemoveItem(source, "money", amount)
end

---@param stash string The name of the stash to register.
---@param label string The label for the stash.
---@param stashConfig table The configuration for the stash.
---@field slots number The number of slots in the stash.
---@field maxweight number The maximum weight the stash can hold.
function Framework.RegisterInventory(stash, label, stashConfig)
    exports.ox_inventory:RegisterStash(stash, label, stashConfig.slots, stashConfig.maxweight, nil)
end

---@param src integer
---@param message string
---@param type "error" | "info" | "success"
function Framework.Notify(src, message, type)
	return lib.notify(src, {
		title = "Property",
		duration = 5000,
		description = message,
		position = "center-right",
		type = type == "inform" and "info" or type,
	})
end