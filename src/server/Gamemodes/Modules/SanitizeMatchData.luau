return function(ctx, leavingPlayer)
	local playersIndex = table.find(ctx.match.players, leavingPlayer)
	if playersIndex then table.remove(ctx.match.players, playersIndex) end

	local survivorsIndex = table.find(ctx.match.survivors, leavingPlayer)
	if survivorsIndex then table.remove(ctx.match.survivors, survivorsIndex) end

	local killersIndex = table.find(ctx.match.killers, leavingPlayer)
	if killersIndex then table.remove(ctx.match.killers, killersIndex) end
end
