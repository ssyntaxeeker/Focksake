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

local crouchWalkAnimation = Animations.Player.CrouchWalk

local function getNextState(ctx)
	local humanoid = ctx.humanoid
	local moveDirection = humanoid.MoveDirection

	if moveDirection.Magnitude == 0 then return "IdleCrouch" end
	return
end

local state: StateMachine.BaseState<string, MovementContext.Context> = {
	id = "WalkCrouch",

	Enter = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid
		local walkTrack = AnimationManager.GetTrack(humanoid.Animator, crouchWalkAnimation)

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

		local walkTrack = AnimationManager.GetTrack(humanoid.Animator, crouchWalkAnimation)
		walkTrack:Stop(0.2)
		-- if switching to crouch idle then just adjust speed to 0 instead

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

		local walkTrack = AnimationManager.GetTrack(humanoid.Animator, crouchWalkAnimation)
		walkTrack:AdjustSpeed(humanoid.WalkSpeed / SPEED_TARGET)
	end,
}

StatesRegistry.RegisterState("Movement", state)
