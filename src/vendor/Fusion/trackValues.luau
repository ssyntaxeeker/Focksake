local function xtypeof(x: unknown)
	local typeString = typeof(x)

	if typeString == "table" then
		local _x = x :: { type: unknown? }
		if typeof(_x.type) == "string" then return _x.type end
	end

	return typeString
end

return function(scope, inst)
	scope = scope:innerScope()
	return function(props)
		for key, value in props do
			local keyType = xtypeof(key)
			if keyType == "SpecialKey" and key.stage == "observer" then key:apply(scope, value, inst) end
		end
	end
end
