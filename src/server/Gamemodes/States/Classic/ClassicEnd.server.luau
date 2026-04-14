local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StatesRegistry = require(ReplicatedStorage.Shared.Util.StatesRegistry)

local state = {
	id = "End",

	Enter = function(_ctx)
		print("[Classic Gamemode] Match ending")

		-- check winning conditions

		workspace:SetAttribute("MatchState", "End")
	end,

	Exit = function(ctx)
		print("[Classic Gamemode] Match ended")

		ctx.janitor:Cleanup()
		ctx.matchEnded = true
	end,

	Update = function(_ctx, _deltaTime) end,
}

StatesRegistry.RegisterState("ClassicGamemode", state)
