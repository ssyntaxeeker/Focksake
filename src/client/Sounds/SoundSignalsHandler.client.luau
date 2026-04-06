local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Net = require(ReplicatedStorage.Packages.Net)
local PlaySound = require(StarterPlayer.StarterPlayerScripts.Client.Sounds.Modules.PlaySound)
local PlaySoundSignal = require(StarterPlayer.StarterPlayerScripts.Client.Sounds.Signals.PlaySoundSignal)
local ReplicateSoundSignal = require(StarterPlayer.StarterPlayerScripts.Client.Sounds.Signals.ReplicateSoundSignal)

local PlaySoundEvent = Net:RemoteEvent("PlaySound")
local ReplicateSoundEvent = Net:RemoteEvent("ReplicateSound")

PlaySoundEvent.OnClientEvent:Connect(PlaySound)

PlaySoundSignal:Connect(PlaySound)
ReplicateSoundSignal:Connect(function(sound: Sound, parent: Instance?)
	ReplicateSoundEvent:FireServer(sound, parent)
end)
