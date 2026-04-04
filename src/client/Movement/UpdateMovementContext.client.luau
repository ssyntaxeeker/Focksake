local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local MovementContext = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.MovementContext)
local Observers = require(ReplicatedStorage.Packages.Observers)
local StartMovementStateMachine = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Signals.StartMovementStateMachine)

local setHumanoidFlag = false

Observers.observeLocalCharacter(function(character: Model)
	local humanoid = character:WaitForChild("Humanoid")

	MovementContext.humanoid = humanoid

	if not setHumanoidFlag then StartMovementStateMachine:Fire() end
	setHumanoidFlag = true
end)
