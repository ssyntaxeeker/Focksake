local states = {}

local StatesRegistry = {}

function StatesRegistry.RegisterState(stateMachineName, state)
	if not states[stateMachineName] then states[stateMachineName] = {} end

	local stateName = state.id
	states[stateMachineName][stateName] = state
end

function StatesRegistry.ReturnStates(stateMachineName)
	return states[stateMachineName]
end

return StatesRegistry
