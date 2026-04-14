local ServerStorage = game:GetService("ServerStorage")

local Maps = ServerStorage.Assets.Maps

local mapsList = {}

for _, map in Maps:GetChildren() do
	if map:GetAttribute("Disabled") then continue end

	table.insert(mapsList, map.Name)
end

local RNG = Random.new()

return function()
	return mapsList[RNG:NextInteger(1, #mapsList)]
end
