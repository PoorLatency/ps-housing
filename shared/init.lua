Framework = {}

RealtorGroup = {
	"realtor",
}

PoliceGroup = {
	"police",
}

function hasApartment(apts)
	for propertyId, _ in pairs(apts) do
		local property = PropertiesTable[propertyId]
		if property.owner then
			return true
		end
	end

	return false
end