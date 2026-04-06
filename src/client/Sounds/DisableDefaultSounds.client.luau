local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local SOUNDS_TO_DISABLE = {
	"Running",
}

Observers.observeLocalCharacter(function(character: Model)
	local rootPart = character:WaitForChild("HumanoidRootPart")

	for _, soundName in SOUNDS_TO_DISABLE do
		local soundInstance: Sound = rootPart:WaitForChild(soundName)
		if not soundInstance or not soundInstance:IsA("Sound") then continue end

		soundInstance.Volume = 0
	end
end)
