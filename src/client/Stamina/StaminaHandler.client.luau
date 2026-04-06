local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local AddStaminaModifier = require(StarterPlayer.StarterPlayerScripts.Client.Stamina.Signals.AddStaminaModifier)
local RemoveStaminaModifier = require(StarterPlayer.StarterPlayerScripts.Client.Stamina.Signals.RemoveStaminaModifier)
local StaminaService = require(StarterPlayer.StarterPlayerScripts.Client.Stamina.Modules.StaminaService)

StaminaService.Set(100)

RunService.RenderStepped:Connect(function(deltaTime: number)
	local computedValue = StaminaService.ComputeValue()
	local value = computedValue.regen and math.abs(computedValue.amount) or -math.abs(computedValue.amount)

	StaminaService.Set(StaminaService.Get() + value * deltaTime)
end)

AddStaminaModifier:Connect(StaminaService.AddModifier)
RemoveStaminaModifier:Connect(StaminaService.RemoveModifier)
