-- Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Components
local WindowComponent = require(ReplicatedStorage:WaitForChild("Source").Components.Window)

-- Promo code app
local function PromoCode(props)
	local PromoCodeController = Knit.GetController("PromoCodeController")
	local SFXController = Knit.GetController("SFXController")

	local closeGui = props.closeGui

	local text, setText = Roact.createBinding("")

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		Contrainer = Roact.createElement(WindowComponent, {
			size = UDim2.fromOffset(400, 300),
			title = "Promo code",
			closeGui = closeGui,
		}, {
			Label = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = "Redeem Promo Code",
				TextSize = 18,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.Ubuntu,
				Size = UDim2.new(1, -40, 0, 50),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 20),
			}),
			Redeem = Roact.createElement("TextButton", {
				Size = UDim2.fromOffset(150, 40),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -10),
				Text = "Redeem",
				TextSize = 14,
				TextColor3 = Color3.fromRGB(0, 0, 0),
				Font = Enum.Font.Ubuntu,
				[Roact.Event.Activated] = function()
					PromoCodeController:Redeem(text:getValue())
				end,
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),
			}),
			Box = Roact.createElement("TextBox", {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -60),
				Size = UDim2.new(1, -20, 0, 120),
				BorderSizePixel = 0,
				ClearTextOnFocus = false,
				TextSize = 12,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.Ubuntu,
				PlaceholderColor3 = Color3.fromRGB(131, 131, 131),
				Text = "",
				PlaceholderText = "Write promo code here...",
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				[Roact.Change.Text] = function(object: TextBox)
					setText(object.Text)
				end,
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 5),
					PaddingRight = UDim.new(0, 5),
					PaddingTop = UDim.new(0, 5),
					PaddingBottom = UDim.new(0, 5),
				}),
			}),
		}),
	})
end

return PromoCode
