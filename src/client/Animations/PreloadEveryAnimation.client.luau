local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local AnimationManager = require(StarterPlayer.StarterPlayerScripts.Client.Animations.Modules.AnimationManager)

local Animations = ReplicatedStorage.Assets.Animations

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

local humanoid = character:WaitForChild("Humanoid")

for _, animation in Animations:GetDescendants() do
	if not animation:IsA("Animation") then continue end

	AnimationManager.GetTrack(humanoid.Animator, animation)
end
