local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local AnimationManager = require(StarterPlayer.StarterPlayerScripts.Client.Animations.Modules.AnimationManager)
local MovementConfig = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Config.MovementConfig)
local MovementContext = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.MovementContext)
local StateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)
local StepWalkspeed = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.StepWalkspeed)

local Animations = ReplicatedStorage.Assets.Animations

local SPEED_TARGET = MovementConfig.WALK_SPEED_TARGET
local ACCELERATION = MovementConfig.WALK_SPEED_ACCELERATION

local walkAnimation = Animations.Player.Walk

local state: StateMachine.BaseState<string, MovementContext.Context> = {
	id = "Walk",

	EnterState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid

		local walkTrack = AnimationManager.GetTrack(humanoid.Animator, walkAnimation)
		if walkTrack.IsPlaying then return end

		walkTrack:Play(0.3)
	end,

	ExitState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid

		local walkTrack = AnimationManager.GetTrack(humanoid.Animator, walkAnimation)
		walkTrack:Stop(0.4)
	end,

	UpdateState = function(ctx: MovementContext.Context, deltaTime: number)
		local humanoid = ctx.humanoid
		humanoid.WalkSpeed = StepWalkspeed(humanoid.WalkSpeed, SPEED_TARGET, ACCELERATION, deltaTime)
	end,

	GetNextState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid
		local moveDirection = humanoid.MoveDirection
		local walkSpeed = humanoid.WalkSpeed

		if moveDirection.Magnitude > 0 then
			if walkSpeed >= MovementConfig.MIN_RUN_SPEED then
				return "Run"
			else
				return
			end
		else
			return "Idle"
		end
	end,
}

return state
