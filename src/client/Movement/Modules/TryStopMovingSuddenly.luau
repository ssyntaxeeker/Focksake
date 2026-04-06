local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local AnimationManager = require(StarterPlayer.StarterPlayerScripts.Client.Animations.Modules.AnimationManager)

local Animations = ReplicatedStorage.Assets.Animations

local MIN_SPEED_TO_STOP_SUDDENLY = 16

local stopAnimation = Animations.Player.StopRun

return function(ctx, speedTarget)
	local humanoid = ctx.humanoid
	local rootPart = humanoid.RootPart

	if humanoid.MoveDirection.Magnitude == 0 and humanoid.WalkSpeed >= MIN_SPEED_TO_STOP_SUDDENLY then
		local speedFactor = math.clamp(humanoid.WalkSpeed / speedTarget, 0, 1)
		ctx.momentum = rootPart.AssemblyLinearVelocity

		local stopRunTrack = AnimationManager.GetTrack(humanoid.Animator, stopAnimation)
		stopRunTrack:AdjustSpeed(4 + (2.25 - 4) * speedFactor) -- this is just lerp, at 0 speed factor it returns 4, at 1 it returns 2.25
		stopRunTrack:Play(0.1, 0.1)
	end
end
