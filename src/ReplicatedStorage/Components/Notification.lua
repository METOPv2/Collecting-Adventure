-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)

-- Theme
local colorTypes = {
	["info"] = {
		accent = Color3.fromRGB(78, 164, 226),
	},
	["warn"] = {
		accent = Color3.fromRGB(234, 113, 26),
	},
	["error"] = {
		accent = Color3.fromRGB(234, 26, 26),
	},
	["sell"] = {
		accent = Color3.fromRGB(49, 201, 62),
	},
}

-- Notification component
local function Notification(props)
	local text: string = props.text
	local title: string = props.title
	local transparency: Roact.Binding = props.transparency
	local type: Roact.Binding = Roact.createBinding(props.type)

	return Roact.createElement("CanvasGroup", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(44, 44, 44),
		BorderSizePixel = 0,
		GroupTransparency = transparency,
	}, {
		UIPadding = Roact.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 3),
			PaddingTop = UDim.new(0, 3),
			PaddingRight = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 5),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = type:map(function(value)
				return (value and colorTypes[value]) and colorTypes[value].accent or Color3.fromRGB(0, 0, 0)
			end),
			Transparency = transparency:map(function(value)
				return math.max(type:getValue() == nil and 0.5 or 0, value)
			end),
		}),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		UIListLayout = Roact.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.Name,
			Padding = UDim.new(0, 3),
		}),
		[0] = Roact.createElement("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.XY,
			TextSize = 14,
			TextColor3 = type:map(function(value)
				return (value and colorTypes[value]) and colorTypes[value].accent or Color3.fromRGB(255, 255, 255)
			end),
			Text = title,
			Font = Enum.Font.Ubuntu,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Right,
		}, {
			UISizeConstraint = Roact.createElement("UISizeConstraint", {
				MaxSize = Vector2.new(400, 200),
			}),
		}),
		[1] = Roact.createElement("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.XY,
			TextSize = 10,
			TextColor3 = Color3.fromRGB(214, 214, 214),
			Text = text,
			Font = Enum.Font.Ubuntu,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Right,
		}, {
			UISizeConstraint = Roact.createElement("UISizeConstraint", {
				MaxSize = Vector2.new(400, 300),
			}),
		}),
	})
end

return Notification
