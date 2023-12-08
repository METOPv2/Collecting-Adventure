-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)

-- Components
local WindowComponent = require(ReplicatedStorage:WaitForChild("Source").Components.Window)

local function Content(props)
	local data = props.data
	local elements = {}

	for i, v in ipairs(data.Content) do
		table.insert(
			elements,
			Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = i % 2 == 0 and 0.9 or 1,
				Text = "- " .. v,
				TextSize = 12,
				TextColor3 = Color3.fromRGB(185, 185, 185),
				Font = Enum.Font.Ubuntu,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.Y,
				TextWrapped = true,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 20),
				}),
			})
		)
	end

	return Roact.createFragment(elements)
end

local function Tabs(props)
	local data = props.data
	local elements = {}

	for _, v in pairs(data) do
		table.insert(
			elements,
			Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 5),
				}),
				[0] = Roact.createElement("TextLabel", {
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					Text = v.Name,
					TextSize = 14,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.Ubuntu,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, 0, 0, 30),
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 10),
					}),
				}),
				[1] = Roact.createElement("Frame", {
					AutomaticSize = Enum.AutomaticSize.Y,
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0.85,
					Size = UDim2.new(1, 0, 0, 0),
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						Padding = UDim.new(0, 0),
					}),
					Content = Roact.createElement(Content, { data = v }),
				}),
			})
		)
	end

	return Roact.createFragment(elements)
end

-- Update log app
local function UpdateLog(props)
	local onClose = props.onClose
	local data = props.data

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		Container = Roact.createElement(WindowComponent, {
			title = "Update log",
			size = UDim2.fromOffset(400, 300),
			onClose = onClose,
		}, {
			Holder = Roact.createElement("ScrollingFrame", {
				Size = UDim2.fromScale(1, 1),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				CanvasSize = UDim2.fromOffset(0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 5,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 5),
				}),
				Tabs = Roact.createElement(Tabs, { data = data }),
			}),
		}),
	})
end

return UpdateLog
