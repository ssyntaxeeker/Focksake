--[[
    A simple solution to when an idiot (Sol) loads a gazillion characters asynchronously at once.

    - Made by, you guessed it, Sol!
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

assert(RunService:IsServer(), "Tried to call server function on client")

local RNG = Random.new()

return function(characters: { Model }, cframes: { CFrame })
	task.spawn(function()
		for _, character in characters do
			local primaryPart = character.PrimaryPart
			if not primaryPart or not primaryPart.Parent then continue end

			local player = Players:GetPlayerFromCharacter(character)
			if not player then
				warn(`Tried to SafePivot a NPC. Breh.`)
				continue
			end

			local targetCFrame = cframes[RNG:NextInteger(1, #cframes)]

			primaryPart:SetNetworkOwner(nil)
			primaryPart.Anchored = true

			task.wait()
			character:PivotTo(targetCFrame)
			RunService.PostSimulation:Wait()

			primaryPart.Anchored = false
			primaryPart:SetNetworkOwner(player)
		end
	end)
end
