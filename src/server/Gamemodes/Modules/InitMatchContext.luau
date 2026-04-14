local ServerScriptService = game:GetService("ServerScriptService")

local CalculateKillerChance = require(ServerScriptService.Server.Gamemodes.Modules.CalculateKillerChance)
local GetReadyPlayers = require(ServerScriptService.Server.Gamemodes.Modules.GetReadyPlayers)

local RNG = Random.new()

-- I know how it can seem rigid to do this BUT:
-- 1. You can just not use this for any gamemode
-- 2. Most gamemodes WILL do this since this is the core of the game
-- So I figured it was worth having
return function(ctx, config)
	assert(config.MAX_KILLERS, `No max killers ;(`)

	ctx.match = {}

	ctx.match.players = GetReadyPlayers()
	ctx.match.survivors = {}
	ctx.match.killers = {}

	for _, player in ctx.match.players do
		if #ctx.match.killers == config.MAX_KILLERS then break end -- putting it here incase MAX_KILLERS is 0. I DON'T CARE ABOUT THE ODDS, I'M A PACIFIST AHHHH
		if RNG:NextNumber() > CalculateKillerChance(ctx, player) then continue end

		table.insert(ctx.match.killers, player)
	end

	ctx.match.timer = 0
end
