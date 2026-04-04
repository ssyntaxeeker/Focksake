return function(current: number, target: number, acceleration: number, deltaTime: number): number
	local diff = target - current
	local step = acceleration * deltaTime
	if math.abs(diff) <= step then return target end

	return current + math.sign(diff) * step
end
