local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local GameContext = require(ServerScriptService.Server.Core.Modules.GameContext)
local StateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)
local StatesRegistry = require(ReplicatedStorage.Shared.Util.StatesRegistry)

local machine

task.wait()

machine = StateMachine.Create("Intermission", StatesRegistry.ReturnStates("Core"), GameContext)

GameContext.transition = function(stateName)
	StateMachine.SetState(machine, stateName)
end

RunService.Heartbeat:Connect(function(deltaTime: number)
	StateMachine.Update(machine, deltaTime)
end)
