-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)

-- Components
local WindowCompoennt = require(ReplicatedStorage:WaitForChild("Source").Components.Window)

local names = {
	FruitBucks = "Fruit bucks",
}

local function Rewards(props)
	local promoCode = props.promoCode
	local elements = {}

	local i = 0
	for key, value in pairs(promoCode.Rewards) do
		i += 1
		table.insert(
			elements,
			Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				BorderSizePixel = 0,
				BackgroundColor3 = (i % 2 == 0 and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(40, 40, 40)),
				RichText = true,
				Text = `- {names[key] or key}: <font size="16"><b>{value}</b></font>`,
				TextSize = 12,
				TextColor3 = Color3.fromRGB(150, 150, 150),
				Font = Enum.Font.Ubuntu,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 20),
				}),
			})
		)
	end

	return Roact.createFragment(elements)
end

-- Promo code rewards app
local function PromoCodeRewards(props)
	local promoCode = props.promoCode
	local closeGui = props.closeGui

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		Container = Roact.createElement(WindowCompoennt, {
			size = UDim2.fromOffset(400, 300),
			title = "Promo code rewards",
			closeGui = closeGui,
		}, {
			Holder = Roact.createElement("ScrollingFrame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				CanvasSize = UDim2.fromOffset(0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 5,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, 1),
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),
				[0] = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, 30),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(50, 50, 50),
					Text = `Promo code: {promoCode.PromoCode}`,
					TextSize = 14,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.Ubuntu,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 10),
					}),
				}),
				Rewards = Roact.createElement(Rewards, { promoCode = promoCode }),
			}),
		}),
	})
end

return PromoCodeRewards
