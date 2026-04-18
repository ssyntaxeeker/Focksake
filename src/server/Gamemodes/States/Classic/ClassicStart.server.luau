local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BindPlayerRemovalCleanup = require(ServerScriptService.Server.Gamemodes.Modules.BindPlayerRemovalCleanup)
local ClassicGamemodeConfig = require(ServerScriptService.Server.Gamemodes.Config.ClassicGamemodeConfig)
local GetRandomMap = require(ServerScriptService.Server.Maps.Modules.GetRandomMap)
local InitMapChests = require(ServerScriptService.Server.Gamemodes.Modules.InitMapChests)
local InitMatchContext = require(ServerScriptService.Server.Gamemodes.Modules.InitMatchContext)
local LoadMapSignal = require(ServerScriptService.Server.Maps.Signals.LoadMapSignal)
local TeleportPlayersToMap = require(ServerScriptService.Server.Gamemodes.Modules.TeleportPlayersToMap)

local StatesRegistry = require(ReplicatedStorage.Shared.Util.StatesRegistry)

local state = {
	id = "Start",

	Enter = function(ctx)
		print("[Classic Gamemode] Starting match")

		InitMatchContext(ctx, ClassicGamemodeConfig)
		BindPlayerRemovalCleanup(ctx)

		local chosenMap = GetRandomMap()
		LoadMapSignal:Fire(chosenMap)

		InitMapChests(ctx)

		task.wait(0.5) -- wait 1/2 second because erm I don't see why not tbh just helps players screen have time to fade in.
		-- also this is safe cause Play is only gonna start when matchStarted is true

		TeleportPlayersToMap(ctx)

		workspace:SetAttribute("MatchState", "Start")
		ctx.matchStarted = true
	end,

	Exit = function(ctx)
		print("[Classic Gamemode] Match started")

		ctx.janitor:Cleanup()
	end,

	Update = function(ctx, _deltaTime)
		if not ctx.matchStarted then return end
		ctx.transition("Play")
	end,
}

StatesRegistry.RegisterState("ClassicGamemode", state)
