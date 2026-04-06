-- written by DylWithlt, thanks!

local function useAttribute(scope, instance: Instance, attributeName: string)
	local value = scope:Value(instance:GetAttribute(attributeName))

	local debugTraceback = debug.traceback()
	local mutExFlag = false

	local function update()
		local success, err = pcall(function()
			if mutExFlag then return end
			mutExFlag = true

			task.defer(function()
				local attribute = instance:GetAttribute(attributeName)
				value:set(attribute or nil)

				mutExFlag = false
			end)
		end)

		if not success then
			mutExFlag = false
			warn(err, debugTraceback)
		end
	end

	table.insert(scope, instance:GetAttributeChangedSignal(attributeName):Connect(update))

	return value
end

return useAttribute
