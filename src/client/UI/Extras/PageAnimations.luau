local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local OPEN_SPRING_SPEED = 30
local OPEN_SPRING_DAMPING = 0.9

local CLOSE_SPRING_SPEED = 20
local CLOSE_SPRING_DAMPING = 1

local PageAnimations = {}

-- gotta make this not leak lol
function PageAnimations.OpenPage(page: CanvasGroup)
	local scope = Fusion:scoped()

	local scale = scope:Value(0.9)
	local offsetY = scope:Value(40)
	local transparency = scope:Value(1)
	local overlayTransparency = scope:Value(1)

	local baseSize = page.Size

	local overlay = scope:New("Frame") {
		Name = "TransitionOverlay",
		Size = baseSize,
		AnchorPoint = page.AnchorPoint,
		Position = page.Position,
		BackgroundColor3 = Color3.new(0, 0.035294, 0.105882),
		Transparency = Fusion.peek(overlayTransparency),
		ZIndex = page.ZIndex + 10,
		Parent = page.Parent,
	}

	local scaleSpring = scope:Spring(scale, OPEN_SPRING_SPEED, OPEN_SPRING_DAMPING)
	local offsetSpring = scope:Spring(offsetY, OPEN_SPRING_SPEED, OPEN_SPRING_DAMPING)
	local transparencySpring = scope:Spring(transparency, OPEN_SPRING_SPEED, OPEN_SPRING_DAMPING)
	local overlaySpring = scope:Spring(overlayTransparency, 19, 1)

	scope:Hydrate(page) {
		Size = scope:Computed(function(use)
			local s = use(scaleSpring)

			return UDim2.new(baseSize.X.Scale * s, baseSize.X.Offset * s, baseSize.Y.Scale * s, baseSize.Y.Offset * s)
		end),

		Position = scope:Computed(function(use)
			local y = use(offsetSpring)
			return UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(0, y)
		end),

		GroupTransparency = scope:Computed(function(use)
			return use(transparencySpring)
		end),
	}

	scope:Hydrate(overlay) {
		Size = scope:Computed(function(use)
			local s = use(scaleSpring)

			return UDim2.new(baseSize.X.Scale * s, baseSize.X.Offset * s, baseSize.Y.Scale * s, baseSize.Y.Offset * s)
		end),

		Position = scope:Computed(function(use)
			local y = use(offsetSpring)
			return UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(0, y)
		end),

		BackgroundTransparency = scope:Computed(function(use)
			return use(overlaySpring)
		end),
	}

	page.Visible = true

	scale:set(1)
	offsetY:set(0)
	transparency:set(0)
	overlayTransparency:set(0)

	task.wait(0.2)

	overlayTransparency:set(1)

	task.delay(1, function() end)
end

function PageAnimations.ClosePage(page: CanvasGroup)
	local scope = Fusion:scoped()

	local offsetY = scope:Value(0)
	local transparency = scope:Value(0)

	local offsetSpring = scope:Spring(offsetY, CLOSE_SPRING_SPEED, CLOSE_SPRING_DAMPING)
	local transparencySpring = scope:Spring(transparency, CLOSE_SPRING_SPEED, CLOSE_SPRING_DAMPING)

	scope:Hydrate(page) {
		Position = scope:Computed(function(use)
			local y = use(offsetSpring)
			return UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(0, y)
		end),

		GroupTransparency = scope:Computed(function(use)
			return use(transparencySpring)
		end),
	}

	offsetY:set(40)
	transparency:set(1)

	task.delay(0.35, function()
		page.Visible = false
	end)
end

return PageAnimations
