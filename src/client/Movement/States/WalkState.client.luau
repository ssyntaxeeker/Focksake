local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local AnimationManager = require(StarterPlayer.StarterPlayerScripts.Client.Animations.Modules.AnimationManager)
local MovementConfig = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Config.MovementConfig)
local MovementContext = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.MovementContext)
local PlayStepSound = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.PlayStepSound)
local StateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)
local StatesRegistry = require(ReplicatedStorage.Shared.Util.StatesRegistry)
local StepWalkspeed = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.StepWalkspeed)
local TryStopMovingSuddenly = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.TryStopMovingSuddenly)

local Animations = ReplicatedStorage.Assets.Animations

local SPEED_TARGET = MovementConfig.WALK_SPEED_TARGET
local ACCELERATION = MovementConfig.WALK_SPEED_ACCELERATION

local walkAnimation = Animations.Player.Walk

local function getNextState(ctx)
	local humanoid = ctx.humanoid
	local moveDirection = humanoid.MoveDirection

	if moveDirection.Magnitude <= 0 then return "Idle" end
	return
end

local state: StateMachine.BaseState<string, MovementContext.Context> = {
	id = "Walk",

	Enter = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid

		local walkTrack = AnimationManager.GetTrack(humanoid.Animator, walkAnimation)

		ctx.janitor:Add(
			walkTrack:GetMarkerReachedSignal("Step"):Connect(function()
				PlayStepSound(humanoid)
			end),
			"Disconnect"
		)

		walkTrack:Play(0.3)
	end,

	Exit = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid

		local walkTrack = AnimationManager.GetTrack(humanoid.Animator, walkAnimation)
		walkTrack:Stop(0.2)

		TryStopMovingSuddenly(ctx, SPEED_TARGET)

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

		local walkTrack = AnimationManager.GetTrack(humanoid.Animator, walkAnimation)
		walkTrack:AdjustSpeed(humanoid.WalkSpeed / SPEED_TARGET)
	end,
}

StatesRegistry.RegisterState("Movement", state)
