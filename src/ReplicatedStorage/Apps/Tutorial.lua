-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Tutorial app
local function Tutorial(props)
	local SFXController = Knit.GetController("SFXController")
	local PromptController = Knit.GetController("PromptController")

	local text = props.text
	local onCancel = props.onCancel

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		Text = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -10),
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = text,
			TextSize = 16,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamMedium,
			BorderSizePixel = 0,
			BackgroundTransparency = 0.4,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			TextStrokeTransparency = 0,
			TextWrapped = true,
			LineHeight = 1.3,
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
			}),
			UISizeConstraint = Roact.createElement("UISizeConstraint", {
				MaxSize = Vector2.new(400, math.huge),
			}),
		}),
		Cancel = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -10, 0, 10),
			Size = UDim2.fromOffset(20, 20),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(227, 20, 20),
			BackgroundTransparency = 0.4,
			Image = "rbxassetid://14578662590",
			[Roact.Event.Activated] = function()
				PromptController:Prompt({
					title = "Cancel tutorial",
					text = "Are you sure you want to cancel the tutorial?",
					button1 = "Yes",
					button2 = "No",
				}):andThen(function(result)
					if result == "Yes" then
						onCancel(true)
					end
				end)
			end,
			[Roact.Event.MouseEnter] = function()
				SFXController:PlaySFX("MouseEnter")
			end,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
		}),
	})
end

return Tutorial
