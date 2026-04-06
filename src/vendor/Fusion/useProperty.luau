local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local TrackValues = require(ReplicatedStorage.Vendor.Fusion.trackValues)

local function useProperty(scope, inst, prop)
	local v = scope:Value(inst[prop])
	TrackValues(scope, inst) {
		[Fusion.Out(prop)] = v,
	}
	return v
end

return useProperty
