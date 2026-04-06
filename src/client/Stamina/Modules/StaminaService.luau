local StarterPlayer = game:GetService("StarterPlayer")

local StaminaPresets = require(StarterPlayer.StarterPlayerScripts.Client.Stamina.Modules.StaminaPresets)
local StaminaValue = require(StarterPlayer.StarterPlayerScripts.Client.Values.StaminaValue)

local modifiers = {}
local stamina = 0

local StaminaService = {}

function StaminaService.ComputeValue()
	for modifier, data in StaminaPresets do
		if not table.find(modifiers, modifier) then continue end

		return data
	end

	return StaminaPresets.Default
end

function StaminaService.AddModifier(modifier)
	if table.find(modifiers, modifier) then return end

	table.insert(modifiers, modifier)
end

function StaminaService.RemoveModifier(modifier)
	local foundIndex = table.find(modifiers, modifier)
	if not foundIndex then return end

	table.remove(modifiers, foundIndex)
end

function StaminaService.Set(newValue)
	newValue = math.clamp(newValue, 0, 100)
	if stamina == newValue then return end

	stamina = math.clamp(newValue, 0, 100)
	StaminaValue:set(stamina)
end

function StaminaService.Get()
	return stamina
end

return StaminaService
