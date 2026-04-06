local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)

export type Context = {
	humanoid: Humanoid?,
	momentum: Vector3?,
	janitor: typeof(Janitor.new()),
}

local ctx: Context = {
	janitor = Janitor.new(),
}

return ctx
