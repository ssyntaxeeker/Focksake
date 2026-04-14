local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CurrentMap = require(ServerScriptService.Server.Maps.Values.CurrentMap)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local SafePivotCharactersAsync = require(ReplicatedStorage.Vendor.SafePivotCharactersAsync)

return function(ctx)
	local mapModel = Fusion.peek(CurrentMap)
	local spawnsFolder = mapModel.Spawns

	local survivorCFrames = {}
	local killerCFrames = {}

	for _, spawnPart in spawnsFolder:GetChildren() do
		if spawnPart:HasTag("Survivor") then
			table.insert(survivorCFrames, spawnPart.CFrame)
		elseif spawnPart:HasTag("Killer") then
			table.insert(killerCFrames, spawnPart.CFrame)
		end
	end

	-- TODO: Maybe add a fallback incase the CFs are nil to TP players to mid of map coords

	local survivorCharacters = {}
	local killerCharacters = {}

	for _, player in ctx.match.survivors do
		local character = player.Character
		if not character then continue end

		table.insert(survivorCharacters, character)
	end

	for _, player in ctx.match.killers do
		local character = player.Character
		if not character then continue end

		table.insert(killerCharacters, character)
	end

	SafePivotCharactersAsync(survivorCharacters, survivorCFrames)
	SafePivotCharactersAsync(killerCharacters, killerCFrames)
end
