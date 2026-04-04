local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local IdleState = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.IdleState)
local MovementContext = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.MovementContext)
local RunState = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.RunState)
local StartMovementStateMachine = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Signals.StartMovementStateMachine)
local StateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)
local WalkState = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.WalkState)

StartMovementStateMachine:Connect(function()
	local machine = StateMachine.new("Idle", { Idle = IdleState, Walk = WalkState, Run = RunState }, MovementContext)

	RunService.RenderStepped:Connect(function(deltaTime: number)
		machine:Update(deltaTime)
	end)
end)
