local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PromptsEnums = require(ReplicatedStorage.Shared.Enums.PromptsEnums)

local chestPromptGui = ReplicatedStorage.Assets.UI.ChestPrompt
local guiBackgroundGradient = chestPromptGui.Background.UIGradient
local originalSize = chestPromptGui.Size

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
chestPromptGui.Parent = playerGui

local janitor = Janitor.new()

local inputHeld = false
local currentAlpha = 0

local function setFill(alpha)
	currentAlpha = alpha

	guiBackgroundGradient.Color = ColorSequence.new {
		ColorSequenceKeypoint.new(0, Color3.fromRGB(19, 19, 19)),
		ColorSequenceKeypoint.new(math.min(1 - alpha, 0.98), Color3.fromRGB(19, 19, 19)),
		ColorSequenceKeypoint.new(math.min(1 - alpha + 0.001, 0.99), Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	}
end

local function createPrompt(proximityPrompt: ProximityPrompt)
	proximityPrompt.PromptShown:Connect(function()
		chestPromptGui.KeyboardText.Text = proximityPrompt.KeyboardKeyCode.Name

		chestPromptGui.Size = UDim2.fromScale(0, 0)
		chestPromptGui.Adornee = proximityPrompt.Parent

		janitor:Add(
			chestPromptGui.Button.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.Touch then return end
				proximityPrompt:InputHoldBegin()
			end),
			"Disconnect"
		)

		janitor:Add(
			chestPromptGui.Button.InputEnded:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.Touch then return end
				proximityPrompt:InputHoldEnd()
			end),
			"Disconnect"
		)

		TweenService:Create(chestPromptGui, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = originalSize }):Play()
	end)

	proximityPrompt.PromptButtonHoldBegan:Connect(function()
		TweenService:Create(
			chestPromptGui,
			TweenInfo.new(proximityPrompt.HoldDuration, Enum.EasingStyle.Quad),
			{ Size = originalSize:Lerp(UDim2.fromScale(2, 2), 0.4) }
		):Play()

		inputHeld = true

		local duration = proximityPrompt.HoldDuration
		local start = os.clock()

		while inputHeld do
			local progress = math.clamp((os.clock() - start) / duration, 0, 1)
			setFill(progress)

			if progress >= 1 then break end

			task.wait()
		end
	end)

	proximityPrompt.PromptButtonHoldEnded:Connect(function()
		TweenService:Create(chestPromptGui, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = originalSize }):Play()

		inputHeld = false

		local startAlpha = currentAlpha

		if startAlpha > 0.95 then
			TweenService:Create(
				chestPromptGui.Background.UIStrokeBorder,
				TweenInfo.new(0.18, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0, true),
				{ Color = Color3.fromRGB(255, 255, 255) }
			):Play()
		end

		task.wait(0.1)

		local start = os.clock()

		while true do
			local t = math.clamp((os.clock() - start) / 0.06, 0, 1)
			local alpha = startAlpha * (1 - t)

			setFill(alpha)

			if t >= 1 then break end
			task.wait()
		end

		setFill(0)
	end)

	proximityPrompt.PromptHidden:Connect(function()
		if chestPromptGui.Adornee ~= proximityPrompt.Parent then return end

		TweenService:Create(chestPromptGui, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = UDim2.fromScale(0, 0) })
			:Play()

		janitor:Cleanup()

		task.wait(0.15)

		if chestPromptGui.Adornee ~= proximityPrompt.Parent then return end
		chestPromptGui.Adornee = nil
	end)
end

CollectionService:GetInstanceAddedSignal(PromptsEnums.CHEST_TAG):Connect(createPrompt)

for _, proximityPrompt in CollectionService:GetTagged(PromptsEnums.CHEST_TAG) do
	createPrompt(proximityPrompt)
end
