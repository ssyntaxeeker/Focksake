local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CoreStatesConfig = require(ServerScriptService.Server.Core.Config.CoreStatesConfig)
local StatesRegistry = require(ReplicatedStorage.Shared.Util.StatesRegistry)

local function getNextState(ctx)
	if ctx.timer > CoreStatesConfig.INTERMISSION_DURATION then return "InGame" end

	return
end

local state = {
	id = "Intermission",

	Enter = function(ctx)
		print("[Core States] Entered Intermission")

		ctx.timer = 0
	end,

	Exit = function(_ctx)
		print("[Core States] Exiting Intermission")
	end,

	Update = function(ctx, deltaTime)
		local nextState = getNextState(ctx)
		if nextState then ctx.transition(nextState) end

		ctx.timer += deltaTime
	end,
}

StatesRegistry.RegisterState("Core", state)
