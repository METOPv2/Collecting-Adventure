-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)

-- Notifications app
local function Notifications()
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		Holder = Roact.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			AnchorPoint = Vector2.one,
			Position = UDim2.new(1, -5, 1, -5),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				Padding = UDim.new(0, 5),
				FillDirection = Enum.FillDirection.Vertical,
			}),
		}),
	})
end

return Notifications
