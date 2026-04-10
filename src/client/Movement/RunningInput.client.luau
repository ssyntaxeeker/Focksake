local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local ForceMovementStateSignal = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Signals.ForceMovementStateSignal)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local InputModule = require(ReplicatedStorage.Vendor.InputModule)
local StaminaValue = require(StarterPlayer.StarterPlayerScripts.Client.Values.StaminaValue)

local runAction = InputModule.action("Run")
local shiftBind = InputModule.binding("RunKey", Enum.KeyCode.LeftShift)
runAction.AddBinding(shiftBind)

local boundRun = runAction.BindToContext("Gameplay")

boundRun.Pressed:Connect(function()
	if Fusion.peek(StaminaValue) < 1 then return end

	ForceMovementStateSignal:Fire("Run")
end)

boundRun.Released:Connect(function()
	ForceMovementStateSignal:Fire("Walk")
end)
