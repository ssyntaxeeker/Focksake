local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local AnimationManager = require(StarterPlayer.StarterPlayerScripts.Client.Animations.Modules.AnimationManager)
local MovementConfig = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Config.MovementConfig)
local MovementContext = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.MovementContext)
local PlayStepSound = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.PlayStepSound)
local StateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)
local StatesRegistry = require(ReplicatedStorage.Shared.Util.StatesRegistry)
local StepWalkspeed = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.StepWalkspeed)

local Animations = ReplicatedStorage.Assets.Animations

local SPEED_TARGET = MovementConfig.CROUCH_SPEED_TARGET
local ACCELERATION = MovementConfig.CROUCH_SPEED_ACCELERATION

local crouchIdleAnimation = Animations.Player.CrouchIdle
local crouchWalkAnimation = Animations.Player.CrouchWalk

local state: StateMachine.BaseState<string, MovementContext.Context> = {
	id = "WalkCrouch",

	EnterState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid
		local isMoving = humanoid.MoveDirection.Magnitude > 0

		if isMoving then
			local walkTrack = AnimationManager.GetTrack(humanoid.Animator, crouchWalkAnimation)

			ctx.janitor:Add(
				walkTrack:GetMarkerReachedSignal("Step"):Connect(function()
					PlayStepSound(humanoid)
				end),
				"Disconnect"
			)

			walkTrack:Play(0.3)
		else
			local idleTrack = AnimationManager.GetTrack(humanoid.Animator, crouchIdleAnimation)
			idleTrack:Play(0.2)
		end
	end,

	ExitState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid

		local idleTrack = AnimationManager.GetTrack(humanoid.Animator, crouchIdleAnimation)
		idleTrack:Stop(0.2)

		local walkTrack = AnimationManager.GetTrack(humanoid.Animator, crouchWalkAnimation)
		walkTrack:Stop(0.2)

		ctx.janitor:Cleanup()
	end,

	UpdateState = function(ctx: MovementContext.Context, deltaTime: number)
		local humanoid = ctx.humanoid
		humanoid.WalkSpeed = StepWalkspeed(humanoid.WalkSpeed, SPEED_TARGET, ACCELERATION, deltaTime)

		local walkTrack = AnimationManager.GetTrack(humanoid.Animator, crouchWalkAnimation)
		walkTrack:AdjustSpeed(humanoid.WalkSpeed / SPEED_TARGET)
	end,

	GetNextState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid
		local moveDirection = humanoid.MoveDirection

		if moveDirection.Magnitude == 0 then return "IdleCrouch" end
		return
	end,
}

StatesRegistry.RegisterState("Movement", state)
