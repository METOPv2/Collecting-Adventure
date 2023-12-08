-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

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
	["levelUp"] = {
		accent = Color3.fromRGB(182, 66, 245),
	},
	["badgeAward"] = {
		accent = Color3.fromRGB(223, 252, 3),
	},
}

-- Notification component
local function Notification(props)
	local SFXController = Knit.GetController("SFXController")

	local closed = false
	local closeUI = props.closeUI
	local onClose = props.onClose
	local text: string = props.text
	local title: string = props.title
	local transparency: Roact.Binding = props.transparency

	local timeline, setTimeline = Roact.createBinding((props.duration >= 0 and 0 or 1))
	local timer = workspace:GetServerTimeNow()

	if props.duration >= 0 then
		coroutine.wrap(function()
			repeat
				setTimeline(math.min((workspace:GetServerTimeNow() - timer) / props.duration, 1))
				task.wait()
			until closed or (workspace:GetServerTimeNow() - timer) >= props.duration
		end)()
	end

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
			Color = (props.type and colorTypes[props.type]) and colorTypes[props.type].accent
				or Color3.fromRGB(0, 0, 0),
			Transparency = transparency:map(function(value)
				return math.max(props.type == nil and 0.5 or 0, value)
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
			TextColor3 = (props.type and colorTypes[props.type]) and colorTypes[props.type].accent
				or Color3.fromRGB(214, 214, 214),
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
		[2] = Roact.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 20),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 10),
				FillDirection = Enum.FillDirection.Horizontal,
			}),
			Dismiss = Roact.createElement("ImageButton", {
				Size = UDim2.fromOffset(14, 14),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Image = "rbxassetid://15421223061",
				[Roact.Event.Activated] = function()
					SFXController:PlaySFX("CloseNotification")
					closed = true
					closeUI()
					if onClose then
						onClose()
					end
				end,
				[Roact.Event.MouseEnter] = function(object: ImageButton)
					SFXController:PlaySFX("MouseEnter")
					object.ImageColor3 = Color3.fromRGB(199, 199, 199)
				end,
				[Roact.Event.MouseLeave] = function(object: ImageButton)
					object.ImageColor3 = Color3.fromRGB(255, 255, 255)
				end,
			}),
		}),
		[3] = Roact.createElement("Frame", {
			Size = UDim2.fromOffset(150, 3),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(125, 125, 125),
		}, {
			Progres = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(255, 255, 255),
				Size = timeline:map(function(value: number)
					return UDim2.fromScale(value, 1)
				end),
			}),
		}),
	})
end

return Notification
