local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local AnimationManager = require(StarterPlayer.StarterPlayerScripts.Client.Animations.Modules.AnimationManager)
local MovementConfig = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Config.MovementConfig)
local MovementContext = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.MovementContext)
local StateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)
local StatesRegistry = require(ReplicatedStorage.Shared.Util.StatesRegistry)
local StepWalkspeed = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.StepWalkspeed)

local Animations = ReplicatedStorage.Assets.Animations

local SPEED_TARGET = MovementConfig.IDLE_SPEED_TARGET
local ACCELERATION = MovementConfig.IDLE_SPEED_ACCELERATION

local crouchIdleAnimation = Animations.Player.CrouchIdle

local function getNextState(ctx)
	local humanoid = ctx.humanoid
	local moveDirection = humanoid.MoveDirection

	if moveDirection.Magnitude > 0 then return "WalkCrouch" end
	return
end

local state: StateMachine.BaseState<string, MovementContext.Context> = {
	id = "IdleCrouch",

	Enter = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid

		local idleTrack = AnimationManager.GetTrack(humanoid.Animator, crouchIdleAnimation)
		idleTrack:Play(0.2)
	end,

	Exit = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid

		local idleTrack = AnimationManager.GetTrack(humanoid.Animator, crouchIdleAnimation)
		idleTrack:Stop(0.2)

		ctx.janitor:Cleanup()
	end,

	Update = function(ctx: MovementContext.Context, deltaTime: number)
		local nextState = getNextState(ctx)
		if nextState then
			ctx.transition(nextState)
			return
		end

		local humanoid = ctx.humanoid
		humanoid.WalkSpeed = StepWalkspeed(humanoid.WalkSpeed, SPEED_TARGET, ACCELERATION, deltaTime)
	end,
}

StatesRegistry.RegisterState("Movement", state)
