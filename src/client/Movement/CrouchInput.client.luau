local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local ForceMovementStateSignal = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Signals.ForceMovementStateSignal)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local InputModule = require(ReplicatedStorage.Vendor.InputModule)
local MovementCurrentState = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Values.MovementCurrentState)

local crouchAction = InputModule.action("Crouch")
local cBind = InputModule.binding("CrouchKey", Enum.KeyCode.C)
crouchAction.AddBinding(cBind)

local boundCrouch = crouchAction.BindToContext("Gameplay")

boundCrouch.Pressed:Connect(function()
	local currentState = Fusion.peek(MovementCurrentState)

	if currentState == "Run" or currentState == "Walk" then
		ForceMovementStateSignal:Fire("WalkCrouch")
	else
		ForceMovementStateSignal:Fire("IdleCrouch")
	end
end)
boundCrouch.Released:Connect(function()
	local currentState = Fusion.peek(MovementCurrentState)

	if currentState == "WalkCrouch" then
		ForceMovementStateSignal:Fire("Walk")
	else
		ForceMovementStateSignal:Fire("Idle")
	end
end)
