local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InteractableEnums = require(ReplicatedStorage.Shared.Enums.InteractableEnums)
local Net = require(ReplicatedStorage.Packages.Net)
local PromptsEnums = require(ReplicatedStorage.Shared.Enums.PromptsEnums)

local Models = ReplicatedStorage.Assets.Models

local CHEST_PROMPT_ACTIVATION_DISTANCE = 6

local StartOpeningChest = Net:RemoteEvent("StartOpeningChest")

local chests = {}

local ChestsManager = {}

function ChestsManager.Create(chestId: number, cframe: CFrame, parent)
	local chest = Models.Chest:Clone()
	chest.Parent = parent

	chest:PivotTo(cframe)

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.KeyboardKeyCode = Enum.KeyCode.F
	proximityPrompt.HoldDuration = 0.5
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.MaxActivationDistance = CHEST_PROMPT_ACTIVATION_DISTANCE
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom

	proximityPrompt.Triggered:Connect(function(player)
		ChestsManager.Open(chestId, player)
	end)

	proximityPrompt.Parent = chest

	proximityPrompt:AddTag(PromptsEnums.CHEST_TAG)
	chest:AddTag(InteractableEnums.CHEST_TAG)

	chests[chestId] = {
		progress = 0,
		maxProgress = 100,

		model = chest,

		slots = { -- It's false just to initialize them :/
			Front = false,
			Left = false,
			Right = false,
		},
	}
end

function ChestsManager.Destroy(chestId: number)
	chests[chestId] = nil
end

function ChestsManager.Open(chestId: number, player: Player)
	local chest = chests[chestId]
	if not chest then
		warn(`Couldn't open chest, no model found for ID {chestId}`)
		return
	end

	-- MOVE PLAYER TO CLOSEST AVAILABLE SLOT
	do
		local character = player.Character
		if not character then
			warn(`Couldn't open chest, no character`)
			return
		end

		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		local bestSlotName = nil
		local bestPart = nil
		local bestDistance = math.huge

		for slotName, occupant in chest.slots do
			if occupant then continue end

			local partName = slotName .. "Root"
			local part = chest.model:FindFirstChild(partName)

			if not part then continue end

			local distance = (rootPart.Position - part.Position).Magnitude
			if distance < bestDistance then
				bestDistance = distance
				bestSlotName = slotName
				bestPart = part
			end
		end

		if not bestSlotName or not bestPart then
			warn(`Couldn't open chest, no available parts for the Player to go to`)
			return
		end

		local chestPosition = chest.model:GetPivot().Position
		local lookAt = Vector3.new(chestPosition.X, bestPart.Position.Y, chestPosition.Z)

		rootPart.CFrame = CFrame.lookAt(bestPart.Position, lookAt)
	end

	-- FIRE PLAYER TO KNEEL AND SHOW UI
	StartOpeningChest:FireClient(player)
end

function ChestsManager.Close(chestId: number, player: Player)
	-- "close" chest
end

return ChestsManager
