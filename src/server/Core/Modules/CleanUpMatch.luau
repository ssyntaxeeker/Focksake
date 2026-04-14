local function reloadCharacters(players)
	if not players then return end

	for _, player in players do
		player:LoadCharacterAsync()
	end
end

return function(ctx)
	if not ctx.match then return end

	reloadCharacters(ctx.match.players)
	ctx.match = nil
end
