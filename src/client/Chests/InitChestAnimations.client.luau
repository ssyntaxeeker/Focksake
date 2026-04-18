local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local AnimationManager = require(StarterPlayer.StarterPlayerScripts.Client.Animations.Modules.AnimationManager)
local InteractableEnums = require(ReplicatedStorage.Shared.Enums.InteractableEnums)

local Animations = ReplicatedStorage.Assets.Animations

local DISTANCE_TO_OPEN_CHEST = 8
local STATE_CHANGE_COOLDOWN = 0.35

local localPlayer = Players.LocalPlayer

local chestsData: {
	[Model]: {
		animations: { open: AnimationTrack, close: AnimationTrack },
		state: "Closed" | "Opening" | "Open" | "Closing",
		targetOpen: boolean,
		lastChange: number,
	},
} =
	{}

do
	local function initChest(chest)
		local animationController = chest:FindFirstChild("AnimationController")
		if not animationController then
			warn(`Couldn't load animations for chest - No AnimationController`, chest)
			return
		end

		local animator = animationController:FindFirstChild("Animator")
		if not animator then
			warn(`Couldn't load animations for chest - No Animator`, chest)
			return
		end

		local openTrack = AnimationManager.GetTrack(animator, Animations.Chest.OpenAnimation)
		local closeTrack = AnimationManager.GetTrack(animator, Animations.Chest.CloseAnimation)

		openTrack:GetMarkerReachedSignal("Completed"):Connect(function()
			local data = chestsData[chest]
			if data then data.state = "Open" end

			openTrack:AdjustSpeed(0)
		end)

		closeTrack:GetMarkerReachedSignal("Completed"):Connect(function()
			local data = chestsData[chest]
			if data then data.state = "Closed" end
		end)

		chestsData[chest] = {
			animations = {
				open = openTrack,
				close = closeTrack,
			},
			state = "Closed",
			targetOpen = false,
			lastChange = 0,
		}
	end

	CollectionService:GetInstanceAddedSignal(InteractableEnums.CHEST_TAG):Connect(initChest)

	for _, chest in CollectionService:GetTagged(InteractableEnums.CHEST_TAG) do
		initChest(chest)
	end
end

do
	local function shouldOpenChest(chest)
		local character = localPlayer.Character
		if not character then return end

		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		local chestPosition = chest.PrimaryPart.Position
		if (rootPart.Position - chestPosition).Magnitude >= DISTANCE_TO_OPEN_CHEST then return end

		return true
	end

	RunService.RenderStepped:Connect(function()
		local now = tick()

		for chest, data in chestsData do
			if not chest or not chest.Parent then
				chestsData[chest] = nil
				continue
			end

			local shouldBeOpen = shouldOpenChest(chest)
			data.targetOpen = shouldBeOpen

			-- respect cooldown cause we aint bishes
			if now - data.lastChange < STATE_CHANGE_COOLDOWN then continue end

			-- OPEN
			if data.targetOpen then
				if data.state == "Closed" or data.state == "Closing" then
					data.state = "Opening"
					data.lastChange = now

					data.animations.close:Stop()
					data.animations.open:Play()

					continue
				end
			end

			-- CLOSE
			if not data.targetOpen then
				if data.state == "Open" or data.state == "Opening" then
					data.state = "Closing"
					data.lastChange = now

					data.animations.open:Stop()
					data.animations.close:Play()

					continue
				end
			end
		end
	end)
end
