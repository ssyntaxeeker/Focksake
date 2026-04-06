--[[
Foul attempt at IAS (even though I never even tried using it until now).
To whoever may read this mess, may something be with you cause God went out the door when he saw who wrote this 

- sol (3693744006)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

local function createInputContext(priority: number?, sinkLowerInputs: boolean?)
	local inputContext: InputContext = Instance.new("InputContext")
	inputContext.Priority = priority or 1000
	inputContext.Sink = sinkLowerInputs or false
	inputContext.Parent = script

	return inputContext
end

local function createInputAction(type: Enum.InputActionType?)
	local inputAction: InputAction = Instance.new("InputAction")
	inputAction.Type = type or Enum.InputActionType.Bool

	return inputAction
end

local function createInputBinding(keyCode: Enum.KeyCode?, uiButton: (ImageButton | TextButton)?)
	local inputBinding: InputBinding = Instance.new("InputBinding")
	if keyCode then inputBinding.KeyCode = keyCode end
	if uiButton then inputBinding.UIButton = uiButton end

	return inputBinding
end

type Signal = typeof(Signal.new())

type Context = {
	Name: string,
	Id: number,
	Instance: InputContext,
	Actions: { [number]: BoundAction },

	Signals: {
		OnActionBound: Signal,
		OnActionUnbound: Signal,
	},
}

type Action = {
	Name: string,
	Id: number,
	Template: InputAction,
	Bindings: { [number]: Binding },
	Bound: { [number]: BoundAction },
}

type BoundAction = {
	Template: Action,
	Context: Context,
	Instance: InputAction,
	Bindings: { [number]: AddedBinding },

	Pressed: RBXScriptSignal,
	Released: RBXScriptSignal,
	StateChanged: RBXScriptSignal,

	Signals: {
		OnBindingAdded: Signal,
		OnBindingRemoved: Signal,
	},
}

type Binding = {
	Name: string,
	Id: number,
	Template: InputBinding,
}

type AddedBinding = {
	Template: Binding,
	Instance: InputBinding,

	GetInstance: () -> InputBinding,
}

local contexts = {}
local actions = {}
local bindings = {}

local contextLUT = {}
local actionLUT = {}
local bindingLUT = {}

local contextId = 0
local actionId = 0
local bindingId = 0

local function getContext(name: string, priority: number?, sink: boolean?): Context
	local existing = contextLUT[name]
	if existing then return existing end

	contextId += 1

	local context: Context = {
		Name = name,
		Id = contextId,
		Instance = createInputContext(priority, sink),
		Actions = {},

		Signals = {
			OnActionBound = Signal.new(),
			OnActionUnbound = Signal.new(),
		},
	}

	contexts[contextId] = context
	contextLUT[name] = context

	return context
end

local function getAction(name: string, type: Enum.InputActionType?): Action
	local existing = actionLUT[name]
	if existing then return existing end

	actionId += 1

	local action: Action = {
		Name = name,
		Id = actionId,
		Template = createInputAction(type),
		Bindings = {},
		Bound = {},
	}

	actions[actionId] = action
	actionLUT[name] = action

	return action
end

local function getBinding(name: string, keyCode: Enum.KeyCode?, uiButton: (ImageButton | TextButton)?): Binding
	local existing = bindingLUT[name]
	if existing then return existing end

	bindingId += 1

	local binding: Binding = {
		Name = name,
		Id = bindingId,
		Template = createInputBinding(keyCode, uiButton),
	}

	bindings[bindingId] = binding
	bindingLUT[name] = binding

	return binding
end

local function attachBinding(bound: BoundAction, binding: Binding)
	if bound.Bindings[binding.Id] then return end

	local clone = binding.Template:Clone()
	clone.Parent = bound.Instance

	local added: AddedBinding = {
		Template = binding,
		Instance = clone,

		GetInstance = function()
			return clone
		end,
	}

	bound.Bindings[binding.Id] = added
	bound.Signals.OnBindingAdded:Fire(binding.Id)
end

local function detachBinding(bound: BoundAction, binding: Binding)
	local existing = bound.Bindings[binding.Id]
	if not existing then return end

	existing.Instance:Destroy()
	bound.Bindings[binding.Id] = nil
	bound.Signals.OnBindingRemoved:Fire(binding.Id)
end

local InputModule = {}

function InputModule.context(contextName: string, priority: number?, sink: boolean?)
	local context = getContext(contextName, priority, sink)

	return {
		GetSignal = function(name: string)
			return context.Signals[name]
		end,

		GetInstance = function()
			return context.Instance
		end,

		GetActions = function()
			return context.Actions
		end,

		BindAction = function(action: Action)
			if context.Actions[action.Id] then return context.Actions[action.Id] end

			local clone = action.Template:Clone()
			clone.Parent = context.Instance

			local bound: BoundAction = {
				Template = action,
				Context = context,
				Instance = clone,
				Bindings = {},

				Pressed = clone.Pressed,
				Released = clone.Released,
				StateChanged = clone.StateChanged,

				Signals = {
					OnBindingAdded = Signal.new(),
					OnBindingRemoved = Signal.new(),
				},
			}

			context.Actions[action.Id] = bound
			action.Bound[context.Id] = bound

			for _, binding in action.Bindings do
				attachBinding(bound, binding)
			end

			context.Signals.OnActionBound:Fire(bound)
			return bound
		end,

		UnbindAction = function(action: Action)
			local bound = context.Actions[action.Id]
			if not bound then return end

			for _, b in bound.Bindings do
				b.Instance:Destroy()
			end

			bound.Instance:Destroy()

			context.Actions[action.Id] = nil
			action.Bound[context.Id] = nil

			context.Signals.OnActionUnbound:Fire(action.Id)
			return action.Id
		end,

		Id = context.Id,
	}
end

function InputModule.action(actionName: string, type: Enum.InputActionType?)
	local action = getAction(actionName, type)

	return {
		BindToContext = function(contextName: string)
			return InputModule.context(contextName).BindAction(action)
		end,

		UnbindFromContext = function(contextName: string)
			return InputModule.context(contextName).UnbindAction(action)
		end,

		AddBinding = function(binding: Binding)
			if action.Bindings[binding.Id] then return false end

			action.Bindings[binding.Id] = binding

			for _, bound in action.Bound do
				attachBinding(bound, binding)
			end

			return true
		end,

		RemoveBinding = function(binding: Binding)
			if not action.Bindings[binding.Id] then return false end

			action.Bindings[binding.Id] = nil

			for _, bound in action.Bound do
				detachBinding(bound, binding)
			end

			return true
		end,

		GetBound = function()
			return action.Bound
		end,

		Id = action.Id,
	}
end

function InputModule.binding(bindingName: string, keyCode: Enum.KeyCode?, uiButton: (ImageButton | TextButton)?)
	return getBinding(bindingName, keyCode, uiButton)
end

return InputModule
