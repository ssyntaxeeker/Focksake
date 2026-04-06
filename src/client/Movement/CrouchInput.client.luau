local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local CurrentState = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Values.CurrentState)
local ForceStateSignal = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Signals.ForceStateSignal)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local InputModule = require(ReplicatedStorage.Vendor.InputModule)

local crouchAction = InputModule.action("Crouch")
local cBind = InputModule.binding("CrouchKey", Enum.KeyCode.C)
crouchAction.AddBinding(cBind)

local boundCrouch = crouchAction.BindToContext("Gameplay")

boundCrouch.Pressed:Connect(function()
	local currentState = Fusion.peek(CurrentState)

	if currentState == "Run" or currentState == "Walk" then
		ForceStateSignal:Fire("WalkCrouch")
	else
		ForceStateSignal:Fire("IdleCrouch")
	end
end)
boundCrouch.Released:Connect(function()
	local currentState = Fusion.peek(CurrentState)

	if currentState == "WalkCrouch" then
		ForceStateSignal:Fire("Walk")
	else
		ForceStateSignal:Fire("Idle")
	end
end)
