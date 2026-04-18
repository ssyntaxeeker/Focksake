local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

local PageAnimations = require(StarterPlayer.StarterPlayerScripts.Client.UI.Extras.PageAnimations)
task.wait(3)

PageAnimations.OpenPage(Players.LocalPlayer.PlayerGui.Pages.TestPage)
task.wait(1)
PageAnimations.ClosePage(Players.LocalPlayer.PlayerGui.Pages.TestPage)
