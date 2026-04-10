local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local ForceMovementStateSignal = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Signals.ForceMovementStateSignal)
local MovementContext = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.MovementContext)
local MovementCurrentState = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Values.MovementCurrentState)
local StartMachineSignal = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Signals.StartMachineSignal)
local StateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)
local StatesRegistry = require(ReplicatedStorage.Shared.Util.StatesRegistry)

local machine

StartMachineSignal:Connect(function()
	machine = StateMachine.Create("Idle", StatesRegistry.ReturnStates("Movement"), MovementContext)

	MovementContext.transition = function(stateName)
		StateMachine.SetState(machine, stateName)
	end

	machine.OnEnter:Connect(function(stateId)
		MovementCurrentState:set(stateId)
	end)

	RunService.RenderStepped:Connect(function(deltaTime: number)
		StateMachine.Update(machine, deltaTime)
	end)
end)

ForceMovementStateSignal:Connect(function(stateName)
	if not machine then return end
	StateMachine.SetState(machine, stateName)
end)
