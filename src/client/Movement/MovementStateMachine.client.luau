local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local CurrentState = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Values.CurrentState)
local ForceStateSignal = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Signals.ForceStateSignal)
local IdleCrouchState = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.IdleCrouchState)
local IdleState = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.IdleState)
local MovementContext = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.MovementContext)
local RunState = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.RunState)
local StartMachineSignal = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Signals.StartMachineSignal)
local StateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)
local WalkCrouchState = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.WalkCrouchState)
local WalkState = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.WalkState)

local machine

StartMachineSignal:Connect(function()
	machine = StateMachine.create(
		"Idle",
		{ Idle = IdleState, Walk = WalkState, Run = RunState, WalkCrouch = WalkCrouchState, IdleCrouch = IdleCrouchState },
		MovementContext
	)

	machine.OnEnter:Connect(function(stateId)
		CurrentState:set(stateId)
	end)

	RunService.RenderStepped:Connect(function(deltaTime: number)
		StateMachine.update(machine, deltaTime)
	end)
end)

ForceStateSignal:Connect(function(stateName)
	if not machine then return end
	machine:SetState(stateName)
end)
