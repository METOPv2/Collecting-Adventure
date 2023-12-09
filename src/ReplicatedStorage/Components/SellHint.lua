-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)

-- Sell hint component
local function SellHint(props)
	local adornee = props.adornee
	local enabled = props.enabled
	return Roact.createElement("BillboardGui", {
		AlwaysOnTop = true,
		Size = UDim2.fromOffset(200, 50),
		Adornee = adornee,
		StudsOffset = Vector3.new(0, 5, 0),
		Enabled = enabled,
		ResetOnSpawn = false,
		MaxDistance = 50,
	}, {
		Text = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = 2,
			AutomaticSize = Enum.AutomaticSize.X,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold),
			TextSize = 14,
			TextColor3 = Color3.fromRGB(27, 27, 27),
			Text = "Walk on the platform below to sell fruits.",
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			UIPadding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),
		}),
		Triangle = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = "rbxassetid://1248849582",
			Size = UDim2.fromOffset(50, 50),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}),
	})
end

return SellHint
