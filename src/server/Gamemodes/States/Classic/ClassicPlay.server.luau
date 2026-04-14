local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BindPlayerRemovalCleanup = require(ServerScriptService.Server.Gamemodes.Modules.BindPlayerRemovalCleanup)
local ClassicGamemodeConfig = require(ServerScriptService.Server.Gamemodes.Config.ClassicGamemodeConfig)
local StatesRegistry = require(ReplicatedStorage.Shared.Util.StatesRegistry)

local function getNextState(ctx)
	if ctx.match.timer >= ClassicGamemodeConfig.DURATION then return "End" end
	return
end

local state = {
	id = "Play",

	Enter = function(ctx)
		print("[Classic Gamemode] Match is in play")

		BindPlayerRemovalCleanup(ctx)

		workspace:SetAttribute("MatchState", "Play")
	end,

	Exit = function(ctx)
		print("[Classic Gamemode] Match is no longer in play")

		ctx.janitor:Cleanup()
	end,

	Update = function(ctx, deltaTime)
		local nextState = getNextState(ctx)
		if nextState then ctx.transition(nextState) end

		ctx.match.timer += deltaTime
	end,
}

StatesRegistry.RegisterState("ClassicGamemode", state)
