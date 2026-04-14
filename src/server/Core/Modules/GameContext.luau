local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)

local context: { transition: (stateName: string) -> nil, janitor: typeof(Janitor.new()) } = {
	janitor = Janitor.new(),
}

return context
