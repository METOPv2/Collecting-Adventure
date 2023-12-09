-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Components
local WindowComponent = require(ReplicatedStorage:WaitForChild("Source").Components.Window)

-- Knit controllers
local FeedbackController = Knit.GetController("FeedbackController")

-- Feedback app
local function Feedback(props)
	local closeGui = props.closeGui

	local text, updateText = Roact.createBinding("")

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		Contrainer = Roact.createElement(WindowComponent, {
			size = UDim2.fromOffset(400, 300),
			title = "Feedback",
			closeGui = closeGui,
		}, {
			TextBox = Roact.createElement("TextBox", {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(48, 48, 48),
				Position = UDim2.fromOffset(10, 10),
				Size = UDim2.new(1, -20, 1, -70),
				Text = "",
				PlaceholderText = "Write your feedback here...",
				TextSize = 12,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				PlaceholderColor3 = Color3.fromRGB(192, 192, 192),
				Font = Enum.Font.Ubuntu,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				[Roact.Change.Text] = function(object)
					updateText(object.Text)
				end,
				TextWrapped = true,
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),
				UIPadding = Roact.createElement("UIPadding", {
					PaddingBottom = UDim.new(0, 5),
					PaddingTop = UDim.new(0, 5),
					PaddingRight = UDim.new(0, 5),
					PaddingLeft = UDim.new(0, 5),
				}),
			}),
			Send = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -10),
				Size = UDim2.fromOffset(150, 40),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				Text = "Send",
				TextSize = 14,
				Font = Enum.Font.Ubuntu,
				[Roact.Event.Activated] = function()
					FeedbackController:Send({ text = text:getValue() })
				end,
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),
			}),
		}),
	})
end

return Feedback
