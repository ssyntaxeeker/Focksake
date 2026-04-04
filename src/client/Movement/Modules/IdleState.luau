local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local AnimationManager = require(StarterPlayer.StarterPlayerScripts.Client.Animations.Modules.AnimationManager)
local MovementConfig = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Config.MovementConfig)
local MovementContext = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.MovementContext)
local StateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)
local StepWalkspeed = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.StepWalkspeed)

local Animations = ReplicatedStorage.Assets.Animations

local SPEED_TARGET = MovementConfig.IDLE_SPEED_TARGET
local ACCELERATION = MovementConfig.IDLE_SPEED_ACCELERATION

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
	end,

	UpdateState = function(ctx: MovementContext.Context, deltaTime: number)
		local humanoid = ctx.humanoid
		humanoid.WalkSpeed = StepWalkspeed(humanoid.WalkSpeed, SPEED_TARGET, ACCELERATION, deltaTime)

		local weightAlpha = math.clamp(humanoid.WalkSpeed / MovementConfig.WALK_SPEED_TARGET, 0, 1)
		local idleTrack = AnimationManager.GetTrack(humanoid.Animator, idleAnimation)
		idleTrack:AdjustWeight(1 - weightAlpha, 0.15)

		local rootPart = humanoid.RootPart
		if ctx.momentum then
			local decay = math.exp(-7.3 * deltaTime)
			ctx.momentum *= decay

			local horizontal = Vector3.new(ctx.momentum.X, 0, ctx.momentum.Z)
			if horizontal.Magnitude < 0.1 then ctx.momentum = nil end

			rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.Y, 0, rootPart.AssemblyLinearVelocity.Z) + horizontal
		end
	end,

	GetNextState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid
		local moveDirection = humanoid.MoveDirection
		local walkSpeed = humanoid.WalkSpeed

		if moveDirection.Magnitude > 0 then
			if walkSpeed >= MovementConfig.MIN_RUN_SPEED then
				return "Run"
			else
				return "Walk"
			end
		end

		return
	end,
}

return state
