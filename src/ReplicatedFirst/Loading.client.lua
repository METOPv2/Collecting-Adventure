local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Loading"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 10

local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.fromScale(1, 1)
background.BorderSizePixel = 0
background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
background.Parent = screenGui

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
})
gradient.Rotation = -90
gradient.Parent = background

local actionText = Instance.new("TextLabel")
actionText.Name = "ActionText"
actionText.Size = UDim2.fromScale(1, 1)
actionText.BorderSizePixel = 0
actionText.BackgroundTransparency = 1
actionText.Text = "Loading"
actionText.TextSize = 14
actionText.TextColor3 = Color3.fromRGB(48, 48, 48)
actionText.Font = Enum.Font.GothamMedium
actionText.ZIndex = 2
actionText.Parent = screenGui

local description = Instance.new("TextLabel")
description.Name = "Description"
description.Size = UDim2.fromScale(0, 0)
description.AnchorPoint = Vector2.new(0.5, 1)
description.Position = UDim2.new(0.5, 0, 1, -10)
description.BackgroundTransparency = 1
description.BorderSizePixel = 0
description.AutomaticSize = Enum.AutomaticSize.XY
description.Text = "Replicating Assets"
description.TextColor3 = Color3.fromRGB(31, 31, 31)
description.TextSize = 12
description.Font = Enum.Font.Ubuntu
description.ZIndex = 2
description.Parent = screenGui

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

screenGui.Parent = playerGui

if not game:IsLoaded() then
	game.Loaded:Wait()
end

screenGui:Destroy()
