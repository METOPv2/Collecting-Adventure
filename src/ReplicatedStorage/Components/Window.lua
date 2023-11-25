-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)

-- Window component
local function Window(props)
	local size = props.size
	local title = props.title
	local onClose = props.onClose

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = size,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(36, 36, 36),
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		TopBar = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 30),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(26, 26, 26),
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			Fill = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 0.5),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(26, 26, 26),
			}),
			Label = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(0.5, 1),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Text = title,
				TextSize = 14,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 2,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 10),
				}),
			}),
			CloseButton = Roact.createElement("ImageButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(14, 14),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = "rbxassetid://15421223061",
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 2,
				[Roact.Event.Activated] = onClose,
				[Roact.Event.MouseEnter] = function(button: ImageButton)
					button.ImageColor3 = Color3.fromRGB(199, 199, 199)
				end,
				[Roact.Event.MouseLeave] = function(button: ImageButton)
					button.ImageColor3 = Color3.fromRGB(255, 255, 255)
				end,
			}),
		}),
		Contrainer = Roact.createElement("Frame", {
			Position = UDim2.fromOffset(0, 30),
			Size = UDim2.new(1, 0, 1, -30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, props[Roact.Children]),
	})
end

return Window
