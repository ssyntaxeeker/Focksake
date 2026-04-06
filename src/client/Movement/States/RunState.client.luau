local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local AddStaminaModifier = require(StarterPlayer.StarterPlayerScripts.Client.Stamina.Signals.AddStaminaModifier)
local AnimationManager = require(StarterPlayer.StarterPlayerScripts.Client.Animations.Modules.AnimationManager)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local MovementConfig = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Config.MovementConfig)
local MovementContext = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.MovementContext)
local PlayStepSound = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.PlayStepSound)
local RemoveStaminaModifier = require(StarterPlayer.StarterPlayerScripts.Client.Stamina.Signals.RemoveStaminaModifier)
local StaminaValue = require(StarterPlayer.StarterPlayerScripts.Client.Values.StaminaValue)
local StateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)
local StatesRegistry = require(ReplicatedStorage.Shared.Util.StatesRegistry)
local StepWalkspeed = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.StepWalkspeed)
local TryStopMovingSuddenly = require(StarterPlayer.StarterPlayerScripts.Client.Movement.Modules.TryStopMovingSuddenly)

local Animations = ReplicatedStorage.Assets.Animations

local SPEED_TARGET = MovementConfig.RUN_SPEED_TARGET
local ACCELERATION = MovementConfig.RUN_SPEED_ACCELERATION

local runAnimation = Animations.Player.Run

local state: StateMachine.BaseState<string, MovementContext.Context> = {
	id = "Run",

	EnterState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid

		local runTrack = AnimationManager.GetTrack(humanoid.Animator, runAnimation)

		ctx.janitor:Add(
			runTrack:GetMarkerReachedSignal("Step"):Connect(function()
				PlayStepSound(humanoid)
			end),
			"Disconnect"
		)

		runTrack:Play(0.4)
		AddStaminaModifier:Fire("Running")
	end,

	ExitState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid

		local runTrack = AnimationManager.GetTrack(humanoid.Animator, runAnimation)
		runTrack:Stop(0.3)

		TryStopMovingSuddenly(ctx, SPEED_TARGET)

		RemoveStaminaModifier:Fire("Running")

		ctx.janitor:Cleanup()
	end,

	UpdateState = function(ctx: MovementContext.Context, deltaTime: number)
		local humanoid = ctx.humanoid
		humanoid.WalkSpeed = StepWalkspeed(humanoid.WalkSpeed, SPEED_TARGET, ACCELERATION, deltaTime)

		local weightAlpha = math.clamp(humanoid.WalkSpeed / SPEED_TARGET, 0, 1)
		local runTrack = AnimationManager.GetTrack(humanoid.Animator, runAnimation)
		runTrack:AdjustWeight(weightAlpha, 0.1)
		runTrack:AdjustSpeed(humanoid.WalkSpeed / SPEED_TARGET)
	end,

	GetNextState = function(ctx: MovementContext.Context)
		local humanoid = ctx.humanoid
		local moveDirection = humanoid.MoveDirection

		if moveDirection.Magnitude > 0 then
			if Fusion.peek(StaminaValue) == 0 then return "Walk" end
		else
			return "Idle"
		end
		return
	end,
}

StatesRegistry.RegisterState("Movement", state)
