local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)

local PlaySoundEvent = Net:RemoteEvent("PlaySound")
local ReplicateSoundEvent = Net:RemoteEvent("ReplicateSound")

ReplicateSoundEvent.OnServerEvent:Connect(function(player: Player, sound: Sound, parent: Instance?)
	for _, _player in Players:GetPlayers() do
		if player == _player then continue end

		PlaySoundEvent:FireClient(_player, sound, parent)
	end
end)
