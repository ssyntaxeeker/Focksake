local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local ForceStateSignal = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Signals.ForceStateSignal)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local InputModule = require(ReplicatedStorage.Vendor.InputModule)
local StaminaValue = require(StarterPlayer.StarterPlayerScripts.Client.Values.StaminaValue)

local runAction = InputModule.action("Run")
local shiftBind = InputModule.binding("RunKey", Enum.KeyCode.LeftShift)
runAction.AddBinding(shiftBind)

local boundRun = runAction.BindToContext("Gameplay")

boundRun.Pressed:Connect(function()
	if Fusion.peek(StaminaValue) < 1 then return end

	ForceStateSignal:Fire("Run")
end)

boundRun.Released:Connect(function()
	ForceStateSignal:Fire("Walk")
end)
