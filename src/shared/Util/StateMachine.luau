local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

export type BaseState<T, C> = {
	id: T,
	Enter: (context: C) -> (),
	Exit: (context: C) -> (),
	Update: (context: C, deltaTime: number) -> (),
	GetNext: (context: C) -> T?,
}

export type Machine<T, C> = {
	states: { [T]: BaseState<T, C> },
	current: BaseState<T, C>,
	context: C,

	OnEnter: any,
	OnStay: any,
	OnExit: any,
}

local StateMachine = {}

function StateMachine.Create<T, C>(initial: T, states: { [T]: BaseState<T, C> }, context: C): Machine<T, C>
	local machine: Machine<T, C> = {
		states = states,
		current = states[initial],
		context = context,

		OnEnter = Signal.new(),
		OnStay = Signal.new(),
		OnExit = Signal.new(),
	}

	local state = machine.current
	state.Enter(context)
	machine.OnEnter:Fire(state.id)

	return machine
end

function StateMachine.Destroy<T, C>(machine: Machine<T, C>)
	if not machine then return end

	local context = machine.context
	local current = machine.current
	if current and current.Exit then current.Exit(context) end

	if machine.OnEnter and machine.OnEnter.Destroy then machine.OnEnter:Destroy() end
	if machine.OnExit and machine.OnExit.Destroy then machine.OnExit:Destroy() end
	if machine.OnStay and machine.OnStay.Destroy then machine.OnStay:Destroy() end

	machine.OnEnter = nil
	machine.OnExit = nil
	machine.OnStay = nil
end

function StateMachine.Update<T, C>(machine: Machine<T, C>, deltaTime: number)
	local state = machine.current
	local context = machine.context

	state.Update(context, deltaTime)
	machine.OnStay:Fire(state.id, deltaTime)
end

function StateMachine.SetState<T, C>(machine: Machine<T, C>, nextStateId: T)
	local current = machine.current
	local nextState = machine.states[nextStateId]

	if not nextState then return end
	local context = machine.context

	current.Exit(context)
	machine.OnExit:Fire(current.id)

	machine.current = nextState

	nextState.Enter(context)
	machine.OnEnter:Fire(nextState.id)
end

function StateMachine.GetState<T, C>(machine: Machine<T, C>): T
	return machine.current.id
end

return StateMachine
