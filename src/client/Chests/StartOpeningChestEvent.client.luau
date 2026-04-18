local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local AnimationManager = require(StarterPlayer.StarterPlayerScripts.Client.Animations.Modules.AnimationManager)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Net = require(ReplicatedStorage.Packages.Net)

local Animations = ReplicatedStorage.Assets.Animations

local StartOpeningChest = Net:RemoteEvent("StartOpeningChest")

local localPlayer = Players.LocalPlayer

local janitor = Janitor.new()

StartOpeningChest.OnClientEvent:Connect(function()
	local character = localPlayer.Character
	if not character then return end

	local humanoid: Humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local startKneelingTrack = AnimationManager.GetTrack(humanoid.Animator, Animations.Player.StartKneeling)
	local kneelingIdleTrack = AnimationManager.GetTrack(humanoid.Animator, Animations.Player.KneelingIdle)

	janitor:Add(
		startKneelingTrack:GetMarkerReachedSignal("Completed"):Once(function()
			kneelingIdleTrack:Play()
		end),
		"Disconnect"
	)

	janitor:Add(function()
		startKneelingTrack:Stop(0.2)
		kneelingIdleTrack:Stop(0.2)
	end, true)

	janitor:Add(
		humanoid.Running:Connect(function(speed)
			if speed <= 0.1 then return end

			janitor:Cleanup()
		end),
		"Disconnect"
	)

	startKneelingTrack:Play()
end)
