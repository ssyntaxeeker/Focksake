local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CreateChestSignal = require(ServerScriptService.Server.Chests.Signals.CreateChestSignal)
local CurrentMap = require(ServerScriptService.Server.Maps.Values.CurrentMap)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local SpawnsEnums = require(ReplicatedStorage.Shared.Enums.SpawnsEnums)

return function(ctx)
	local currentMap = Fusion.peek(CurrentMap)
	for _, chestSpawn in currentMap.Locations:GetDescendants() do
		if not chestSpawn:HasTag(SpawnsEnums.CHEST_TAG) then continue end

		local chestId = ctx.nextChestId
		ctx.nextChestId += 1

		CreateChestSignal:Fire(chestId, chestSpawn.CFrame, currentMap.Runtime)
	end
end
