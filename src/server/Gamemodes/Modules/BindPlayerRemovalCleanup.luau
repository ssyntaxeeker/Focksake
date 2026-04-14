local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local SanitizeMatchData = require(ServerScriptService.Server.Gamemodes.Modules.SanitizeMatchData)

return function(ctx)
	ctx.janitor:Add(
		Players.PlayerRemoving:Connect(function(player)
			SanitizeMatchData(ctx, player)
		end),
		"Disconnect"
	)
end
