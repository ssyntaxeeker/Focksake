local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")

local PlaySoundSignal = require(StarterPlayer.StarterPlayerScripts.Client.Sounds.Signals.PlaySoundSignal)
local ReplicateSoundSignal = require(StarterPlayer.StarterPlayerScripts.Client.Sounds.Signals.ReplicateSoundSignal)

local MovementSFX = SoundService.MovementSFX

return function(humanoid: Humanoid)
	local floorMaterial = humanoid.FloorMaterial

	local stepSound = MovementSFX:FindFirstChild(floorMaterial.Name)
	if not stepSound then stepSound = MovementSFX.SmoothPlastic end

	PlaySoundSignal:Fire(stepSound, humanoid.RootPart)
	ReplicateSoundSignal:Fire(stepSound, humanoid.RootPart)
end
