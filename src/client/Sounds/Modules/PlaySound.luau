local SoundService = game:GetService("SoundService")

local RNG = Random.new()

local function addVariance(soundInstance: Sound)
	soundInstance.PlaybackSpeed += RNG:NextNumber(-0.1, 0.1)
end

return function(sound: Sound, parent: Instance?)
	if not sound then
		warn(`Couldn't play sound - No instance`)
		return
	end
	if not parent then
		SoundService:PlayLocalSound(sound)
		return
	end

	local soundInstance = sound:Clone()
	soundInstance.Parent = parent

	soundInstance.Ended:Connect(function()
		soundInstance:Destroy()
	end)

	addVariance(soundInstance)
	soundInstance:Play()
end
