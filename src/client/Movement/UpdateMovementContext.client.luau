local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local MovementContext = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.MovementContext)
local Observers = require(ReplicatedStorage.Packages.Observers)
local StartMachineSignal = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Signals.StartMachineSignal)

local setHumanoidFlag = false

task.wait()

Observers.observeLocalCharacter(function(character: Model)
	local humanoid = character:WaitForChild("Humanoid")

	MovementContext.humanoid = humanoid

	if not setHumanoidFlag then StartMachineSignal:Fire() end
	setHumanoidFlag = true
end)
