local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local skillCheckGui = player:WaitForChild("PlayerGui"):WaitForChild("SkillCheck")

local movingBar = skillCheckGui.MovingBar
local goalIndicator = skillCheckGui.GoalIndicator
local background = skillCheckGui.Background

local backgroundCenter = background.AbsolutePosition + background.AbsoluteSize / 2
local guiAbsolutePosition = skillCheckGui.AbsolutePosition

local CONFIG = {
	BaseSpeed = 140,
	SpeedGain = 18,

	HitWindow = 15,

	ShakeTime = 0.14,
	ShakeStrength = 0.22,

	HitColor = Color3.fromRGB(80, 255, 120),
	MissColor = Color3.fromRGB(255, 70, 70),
}

local state = {
	angle = 0,
	speed = CONFIG.BaseSpeed,
	direction = 1,

	active = false,
	target = 0,
	shaking = false,
}

local function normalize(angle)
	angle = angle % 360
	if angle < 0 then
		angle += 360
	end

	return angle
end

local function getAngleDelta(angle1, angle2)
	local difference = math.abs(normalize(angle1) - normalize(angle2))
	return math.min(difference, 360 - difference)
end

do
	local function updateMovingBar()
		movingBar.Position = UDim2.fromOffset(backgroundCenter.X - guiAbsolutePosition.X, backgroundCenter.Y - guiAbsolutePosition.Y)
		movingBar.Rotation = state.angle
	end

	local function updateGoalIndicator(angle)
		local radius = (background.AbsoluteSize.X / 2) - 18
		local radianAngle = math.rad(angle - 90)

		local x = backgroundCenter.X + math.cos(radianAngle) * radius
		local y = backgroundCenter.Y + math.sin(radianAngle) * radius

		goalIndicator.Position = UDim2.fromOffset(x - guiAbsolutePosition.X, y - guiAbsolutePosition.Y)
		goalIndicator.Rotation = angle
	end

	local function newTarget()
		state.target = math.random(0, 359)
		updateGoalIndicator(state.target)
	end

	local function hit()
		state.speed += CONFIG.SpeedGain

		TweenService
			:Create(background, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), { ImageColor3 = CONFIG.HitColor })
			:Play()

		newTarget()
	end

	local function miss()
		state.speed = math.max(CONFIG.BaseSpeed, state.speed - CONFIG.SpeedGain)

		TweenService
			:Create(background, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), { ImageColor3 = CONFIG.MissColor })
			:Play()

		if not state.shaking then
			state.shaking = true

			local cam = workspace.CurrentCamera
			local start = cam.CFrame
			local t0 = os.clock()

			local conn
			conn = RunService.RenderStepped:Connect(function()
				local t = os.clock() - t0

				if t >= CONFIG.ShakeTime then
					conn:Disconnect()
					cam.CFrame = start
					state.shaking = false
					return
				end

				local offset = Vector3.new((math.random() - 0.5) * 2 * CONFIG.ShakeStrength, (math.random() - 0.5) * 2 * CONFIG.ShakeStrength, 0)
				cam.CFrame = start * CFrame.new(offset)
			end)
		end

		newTarget()
	end

	local function check()
		return getAngleDelta(state.angle, state.target) <= CONFIG.HitWindow
	end

	local function input()
		if not state.active then return end

		state.dir *= -1

		if check() then
			hit()
		else
			miss()
		end
	end

	local function reset()
		state.angle = 0
		state.speed = CONFIG.BaseSpeed
		state.dir = 1

		newTarget()
		updateMovingBar()
	end

	UserInputService.InputBegan:Connect(function(i, gpe)
		if gpe then return end
		if i.KeyCode == Enum.KeyCode.Space then input() end
	end)

	RunService.RenderStepped:Connect(function(dt)
		if not state.active then return end
		state.angle = normalize(state.angle + state.speed * state.dir * dt)
		updateMovingBar()
	end)

	reset()
	state.active = true
end
