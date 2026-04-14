local function getBaseChance(ctx)
	return 1 / #ctx.match.players
end

-- Allows for players to have their own chance boost too
return function(ctx, _player): number
	local baseChance = getBaseChance(ctx)

	return baseChance -- [0, 1]
end
