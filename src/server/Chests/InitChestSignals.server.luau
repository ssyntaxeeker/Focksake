local ServerScriptService = game:GetService("ServerScriptService")

local ChestsManager = require(ServerScriptService.Server.Chests.Modules.ChestsManager)
local CreateChestSignal = require(ServerScriptService.Server.Chests.Signals.CreateChestSignal)

CreateChestSignal:Connect(ChestsManager.Create)
