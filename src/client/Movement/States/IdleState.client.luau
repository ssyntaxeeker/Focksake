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
local MOMENTUM_DECAY_RATE = MovementConfig.MOMENTUM_DECAY_RATE
local MOMENTUM_CUTOFF = MovementConfig.MOMENTUM_MIN_THRESHOLD

local idleAnimation = Animations.Player.Idle

local state: StateMachine.BaseState<string, MovementContext.Context> = {
	id = "Idle",

	EnterState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid

		local idleTrack = AnimationManager.GetTrack(humanoid.Animator, idleAnimation)
		idleTrack:Play(0.2)
	end,

	ExitState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid

		local idleTrack = AnimationManager.GetTrack(humanoid.Animator, idleAnimation)
		idleTrack:Stop(0.4)

		ctx.janitor:Cleanup()
	end,

	UpdateState = function(ctx: MovementContext.Context, deltaTime: number)
		local humanoid = ctx.humanoid
		humanoid.WalkSpeed = StepWalkspeed(humanoid.WalkSpeed, SPEED_TARGET, ACCELERATION, deltaTime)

		local weightAlpha = math.clamp(humanoid.WalkSpeed / MovementConfig.WALK_SPEED_TARGET, 0, 1)
		local idleTrack = AnimationManager.GetTrack(humanoid.Animator, idleAnimation)
		idleTrack:AdjustWeight(1 - weightAlpha, 0.15)

		local rootPart = humanoid.RootPart
		if ctx.momentum then
			local decayFactor = math.exp(-MOMENTUM_DECAY_RATE * deltaTime)
			ctx.momentum *= decayFactor

			local horizontalMomentum = Vector3.new(ctx.momentum.X, 0, ctx.momentum.Z)
			if horizontalMomentum.Magnitude < MOMENTUM_CUTOFF then
				ctx.momentum = nil
			else
				local velocity = rootPart.AssemblyLinearVelocity
				rootPart.AssemblyLinearVelocity = Vector3.new(velocity.X, 0, velocity.Z) + horizontalMomentum
			end
		end
	end,

	GetNextState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid
		local moveDirection = humanoid.MoveDirection

		if moveDirection.Magnitude > 0 then return "Walk" end
		return
	end,
}

StatesRegistry.RegisterState("Movement", state)
