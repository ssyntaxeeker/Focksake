local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Observers = require(ReplicatedStorage.Packages.Observers)
local useProperty = require(ReplicatedStorage.Vendor.Fusion.useProperty)

local MIN_WALKSPEED = 0
local MAX_WALKSPEED = 24

local MIN_FOV = 50
local MAX_FOV = 85

local LERP_ALPHA = 0.7

local function map(speed: number)
	local t = math.clamp((speed - MIN_WALKSPEED) / (MAX_WALKSPEED - MIN_WALKSPEED), 0, 1)
	return MIN_FOV + (MAX_FOV - MIN_FOV) * t
end

local function updateCameraFOV(speed: number)
	local camera = Workspace.CurrentCamera
	if not camera then return end

	local target = map(speed)
	camera.FieldOfView = camera.FieldOfView + (target - camera.FieldOfView) * LERP_ALPHA
end

Observers.observeLocalCharacter(function(character: Model)
	local humanoid = character:WaitForChild("Humanoid")

	local scope = Fusion:scoped()
	local walkspeedChange = useProperty(scope, humanoid, "WalkSpeed")

	scope:Observer(walkspeedChange):onBind(function()
		updateCameraFOV(Fusion.peek(walkspeedChange))
	end)

	return function()
		scope:doCleanup()
	end
end)
