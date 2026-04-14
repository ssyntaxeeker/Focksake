local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)
local StatesRegistry = require(ReplicatedStorage.Shared.Util.StatesRegistry)

local function getNextState(ctx)
	if ctx.matchEnded then return "Intermission" end -- ctx.matchEnded is to be set by the child FSM
	return
end

local state = {
	id = "InGame",

	Enter = function(ctx)
		print("[Core States] Match started")

		ctx.inGameMachine = StateMachine.Create("Start", StatesRegistry.ReturnStates("ClassicGamemode"), ctx)
	end,

	Exit = function(ctx)
		print("[Core States] Match ended")

		StateMachine.Destroy(ctx.inGameMachine)
	end,

	Update = function(ctx, deltaTime)
		local nextState = getNextState(ctx)
		if nextState then ctx.transition(nextState) end

		if ctx.inGameMachine then StateMachine.Update(ctx.inGameMachine, deltaTime) end
	end,
}

StatesRegistry.RegisterState("Core", state)
