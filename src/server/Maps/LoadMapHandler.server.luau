local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local CurrentMap = require(ServerScriptService.Server.Maps.Values.CurrentMap)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local LoadMapSignal = require(ServerScriptService.Server.Maps.Signals.LoadMapSignal)

local Maps = ServerStorage.Assets.Maps

LoadMapSignal:Connect(function(mapName)
	local mapModel = Maps:FindFirstChild(mapName)
	if not mapModel then
		warn(`Couldn't load map {mapName} - No map model found for map name`)
		return
	end

	local lastMap = Fusion.peek(CurrentMap)

	local map = mapModel:Clone()
	map.Name = "Map"
	map.Parent = workspace
	map:PivotTo(CFrame.new(500, 50, 500)) -- just figured it's good enough tbh

	CurrentMap:set(map)

	if lastMap then lastMap:Destroy() end
end)
