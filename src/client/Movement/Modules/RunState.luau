local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local AnimationManager = require(StarterPlayer.StarterPlayerScripts.Client.Animations.Modules.AnimationManager)
local MovementConfig = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Config.MovementConfig)
local MovementContext = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.MovementContext)
local StateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)
local StepWalkspeed = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.StepWalkspeed)

local Animations = ReplicatedStorage.Assets.Animations

local SPEED_TARGET = MovementConfig.RUN_SPEED_TARGET
local ACCELERATION = MovementConfig.RUN_SPEED_ACCELERATION

local runAnimation = Animations.Player.Run
local stopRunAnimation = Animations.Player.StopRun

local state: StateMachine.BaseState<string, MovementContext.Context> = {
	id = "Run",

	EnterState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid

		local runTrack = AnimationManager.GetTrack(humanoid.Animator, runAnimation)
		if runTrack.IsPlaying then return end

		runTrack:Play(0.4)
	end,

	ExitState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid
		local rootPart = humanoid.RootPart

		local runTrack = AnimationManager.GetTrack(humanoid.Animator, runAnimation)
		runTrack:Stop(0.3)

		if humanoid.MoveDirection.Magnitude == 0 then
			local speedFactor = math.clamp(humanoid.WalkSpeed / SPEED_TARGET, 0, 1)
			ctx.momentum = rootPart.AssemblyLinearVelocity

			local stopRunTrack = AnimationManager.GetTrack(humanoid.Animator, stopRunAnimation)
			stopRunTrack:AdjustSpeed(4.5 + (2.75 - 4.5) * speedFactor) -- this is just lerp, at 0 speed factor it returns 4.5, at 1 it returns 2.75
			stopRunTrack:Play(0.1, 0.15)
		end
	end,

	UpdateState = function(ctx: MovementContext.Context, deltaTime: number)
		local humanoid = ctx.humanoid
		humanoid.WalkSpeed = StepWalkspeed(humanoid.WalkSpeed, SPEED_TARGET, ACCELERATION, deltaTime)

		local weightAlpha = math.clamp(humanoid.WalkSpeed / SPEED_TARGET, 0, 1)
		local runTrack = AnimationManager.GetTrack(humanoid.Animator, runAnimation)
		runTrack:AdjustWeight(weightAlpha, 0.1)
	end,

	GetNextState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid
		local moveDirection = humanoid.MoveDirection
		local walkSpeed = humanoid.WalkSpeed

		if moveDirection.Magnitude > 0 then
			if walkSpeed >= MovementConfig.MIN_RUN_SPEED then return end

			return "Walk"
		else
			return "Idle"
		end
	end,
}

return state
