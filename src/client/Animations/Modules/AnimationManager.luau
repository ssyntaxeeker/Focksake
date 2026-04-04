-- client/Animations/AnimationManager.luau | 0x4571

local animationCache: { [Animator]: { [Animation]: AnimationTrack } } = {}

--[=[
	@class AnimationManager
	Caches and loads animations per Animator to avoid redundant playback calls.
]=]
local AnimationManager = {}

--[=[
	@within AnimationManager
	@function GetTrack
	Returns a cached or newly loaded AnimationTrack for the given Animator.
]=]
function AnimationManager.GetTrack(animator: Animator, animation: Animation): AnimationTrack?
	local cache = animationCache[animator]
	if not cache then
		animationCache[animator] = {}
		cache = animationCache[animator]

		animator.AncestryChanged:Connect(function(_, newParent)
			if newParent then return end

			animationCache[animator] = nil
		end)
	end

	if not animationCache[animator][animation] then -- if the animationTrack doesn't exist (yet)
		local success, track = pcall(function()
			return animator:LoadAnimation(animation)
		end)
		if not success then return end

		animationCache[animator][animation] = track
		track:Play(nil, 0)
	end

	return animationCache[animator][animation]
end

return AnimationManager
