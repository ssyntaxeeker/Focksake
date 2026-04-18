local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StarterPlayer = game:GetService("StarterPlayer")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local StaminaValue = require(StarterPlayer.StarterPlayerScripts.Client.Values.StaminaValue)

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui

local inGameHUD = playerGui:WaitForChild("InGameHUD")
local statsFrame = inGameHUD.StatsFrame

local scope = Fusion:scoped()

-- STAMINA BAR
do
	local staminaBar = statsFrame.StaminaBar

	local function updateStamina()
		local stamina = Fusion.peek(StaminaValue)
		local percent = math.clamp(stamina / 100, 0, 1)

		local transparencySequence

		if percent >= 1 then
			transparencySequence = NumberSequence.new(0)
		else
			transparencySequence = NumberSequence.new {
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(percent, 0),
				NumberSequenceKeypoint.new(math.min(percent + 0.001, 1), 1),
				NumberSequenceKeypoint.new(1, 1),
			}
		end

		staminaBar.CanvasGroup.Fill.UIGradient.Transparency = transparencySequence
		staminaBar.StaminaAmount.Text = `{math.floor(stamina)}/100`
	end

	scope:Observer(StaminaValue):onBind(updateStamina)
end
