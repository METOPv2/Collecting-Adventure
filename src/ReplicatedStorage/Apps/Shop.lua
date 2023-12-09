-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Assets
local bagsAssets = ReplicatedStorage:WaitForChild("Assets").Bags

-- Fruit bucks products
local fruitBucksProducts = {
	{
		ProductId = 1694976189,
		FruitBucks = 5,
	},
	{
		ProductId = 1694976191,
		FruitBucks = 25,
	},
	{
		ProductId = 1694976188,
		FruitBucks = 50,
	},
	{
		ProductId = 1694976190,
		FruitBucks = 100,
	},
}

-- Components
local WindowComponent = require(ReplicatedStorage:WaitForChild("Source").Components.Window)

local function Tab(props)
	local SFXController = Knit.GetController("SFXController")

	local text = props.text
	local activeTab = props.activeTab
	local changeActiveTab = props.changeActiveTab

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 20),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = activeTab:map(function(value)
				if text == "Fruit Bucks" then
					return value == text and Color3.fromRGB(55, 231, 76) or Color3.fromRGB(28, 130, 40)
				end

				return value == text and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(167, 167, 167)
			end),
		}),
		Button = Roact.createElement("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Text = text,
			TextSize = 12,
			TextColor3 = activeTab:map(function(value)
				if text == "Fruit Bucks" then
					return value == text and Color3.fromRGB(55, 231, 76) or Color3.fromRGB(28, 130, 40)
				end

				return value == text and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(167, 167, 167)
			end),
			Font = Enum.Font.Ubuntu,
			[Roact.Event.Activated] = function()
				changeActiveTab(text)
			end,
			[Roact.Event.MouseEnter] = function()
				SFXController:PlaySFX("MouseEnter")
			end,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 5),
			}),
		}),
	})
end

local function Tabs(props)
	local tabs = props.tabs
	local activeTab = props.activeTab
	local changeActiveTab = props.changeActiveTab
	local elements = {}

	table.insert(
		elements,
		Roact.createElement(Tab, {
			text = "Fruit Bucks",
			activeTab = activeTab,
			changeActiveTab = changeActiveTab,
		})
	)

	for _, tab in ipairs(tabs) do
		table.insert(
			elements,
			Roact.createElement(Tab, {
				text = tab,
				activeTab = activeTab,
				changeActiveTab = changeActiveTab,
			})
		)
	end

	return Roact.createFragment(elements)
end

local function Holder(props)
	local name = props.name
	local activeTab = props.activeTab
	local itemsElement = props.itemsElement

	return Roact.createElement("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.fromOffset(0, 0),
		ClipsDescendants = false,
		Visible = activeTab:map(function(value)
			return value == name
		end),
	}, {
		UIGridLayout = Roact.createElement("UIGridLayout", {
			CellSize = UDim2.fromOffset(50, 50),
			CellPadding = UDim2.fromOffset(5, 5),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.Name,
			FillDirection = Enum.FillDirection.Horizontal,
		}),
		Items = itemsElement,
	})
end

local function Bag(props)
	local ShopController = Knit.GetController("ShopController")
	local PlayerEquipmentController = Knit.GetController("PlayerEquipmentController")
	local SFXController = Knit.GetController("SFXController")

	local bag = props.bag
	local model: Model = bagsAssets:FindFirstChild(bag.Id):Clone()
	local size: Vector3 = model:GetExtentsSize()
	local pivot: CFrame = model:GetPivot()
	local cameraRef = Roact.createRef()
	local hovering, updateHover = Roact.createBinding(false)

	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(46, 46, 46),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(50, 50),
	}, {
		UIStroke = Roact.createElement("UIStroke", {
			Transparency = 0.8,
		}),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		Equip = Roact.createElement("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 2,
			[Roact.Event.Activated] = function()
				ShopController:BuyBag(bag.Id)
			end,
			[Roact.Event.MouseEnter] = function()
				updateHover(true)
				SFXController:PlaySFX("MouseEnter")
			end,
			[Roact.Event.MouseLeave] = function()
				updateHover(false)
			end,
		}),
		ViewportFrame = Roact.createElement("ViewportFrame", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			CurrentCamera = cameraRef,
			LightColor = Color3.fromRGB(255, 255, 255),
		}, {
			Camera = Roact.createElement("Camera", {
				CFrame = CFrame.lookAt(pivot.Position + size, pivot.Position),
				[Roact.Ref] = cameraRef,
			}),
			WorldModel = Roact.createElement("WorldModel", {
				[Roact.Ref] = function(ref)
					model.Parent = ref
				end,
			}),
		}),
		Info = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(46, 46, 46),
			AutomaticSize = Enum.AutomaticSize.XY,
			Visible = hovering,
			ZIndex = 3,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				SortOrder = Enum.SortOrder.Name,
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Transparency = 0.8,
				Color = Color3.fromRGB(255, 255, 255),
			}),
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			UIPadding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
			}),
			[0] = Roact.createElement("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = bag.Name,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				Font = Enum.Font.Ubuntu,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				ZIndex = 4,
			}),
			[1] = Roact.createElement("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = `Capacity: {bag.MaxFruits}`,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 12,
				Font = Enum.Font.Ubuntu,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				ZIndex = 4,
			}),
			[2] = Roact.createElement("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = PlayerEquipmentController:DoOwnBag(bag.Id) and "Owned"
					or `Price: {bag.Price == 0 and "Free" or bag.Price}`,
				TextColor3 = Color3.fromRGB(37, 199, 56),
				TextSize = 12,
				Font = Enum.Font.Ubuntu,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				ZIndex = 4,
			}),
		}),
	})
end

local function Bags()
	local PlayerEquipmentController = Knit.GetController("PlayerEquipmentController")
	local bagData = PlayerEquipmentController:GetBagData()
	local elements = {}

	for _, value in pairs(bagData) do
		table.insert(elements, Roact.createElement(Bag, { bag = value }))
	end

	return Roact.createFragment(elements)
end

local function FruitBucksProduct(props)
	local SFXController = Knit.GetController("SFXController")
	local MonetizationController = Knit.GetController("MonetizationController")

	local product = props.product

	return Roact.createElement("Frame", {
		Size = UDim2.fromOffset(50, 50),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(46, 46, 46),
	}, {
		UIStroke = Roact.createElement("UIStroke", {
			Transparency = 0.8,
		}),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		Buy = Roact.createElement("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 2,
			[Roact.Event.Activated] = function()
				MonetizationController:BuyProduct(product.ProductId)
			end,
			[Roact.Event.MouseEnter] = function()
				SFXController:PlaySFX("MouseEnter")
			end,
		}),
		Amount = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Text = product.FruitBucks,
			TextSize = 14,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.Ubuntu,
		}),
	})
end

local function FruitBucksProducts()
	local elements = {}

	for _, product in ipairs(fruitBucksProducts) do
		table.insert(elements, Roact.createElement(FruitBucksProduct, { product = product }))
	end

	return Roact.createFragment(elements)
end

-- Shop app
local Shop = Roact.Component:extend("Shop")

function Shop:render()
	local closeGui = self.props.closeGui
	local starterPage = self.props.starterPage

	local activeTab, changeActiveTab = Roact.createBinding(starterPage and starterPage or "Bags")

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		Contrainer = Roact.createElement(WindowComponent, {
			title = "Shop",
			size = UDim2.fromOffset(400, 300),
			closeGui = closeGui,
		}, {
			Tabs = Roact.createElement("ScrollingFrame", {
				Size = UDim2.new(0, 150, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(31, 31, 31),
				CanvasSize = UDim2.fromOffset(0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 5,
				ScrollingDirection = Enum.ScrollingDirection.Y,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 6),
					PaddingBottom = UDim.new(0, 6),
					PaddingTop = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
				}),
				UIListLayout = Roact.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 6),
					SortOrder = Enum.SortOrder.Name,
				}),
				Tabs = Roact.createElement(
					Tabs,
					{ activeTab = activeTab, changeActiveTab = changeActiveTab, tabs = { "Bags" } }
				),
			}),
			Contrainer = Roact.createElement("Frame", {
				Position = UDim2.fromOffset(150, 0),
				Size = UDim2.new(1, -150, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				Bags = Roact.createElement(
					Holder,
					{ name = "Bags", itemsElement = Roact.createElement(Bags), activeTab = activeTab }
				),
				FruitBucks = Roact.createElement("ScrollingFrame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ScrollBarThickness = 5,
					ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					CanvasSize = UDim2.fromOffset(0, 0),
					ClipsDescendants = false,
					Visible = activeTab:map(function(tab)
						return tab == "Fruit Bucks"
					end),
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						Wraps = true,
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 5),
						SortOrder = Enum.SortOrder.Name,
					}),
					Products = Roact.createElement(FruitBucksProducts),
				}),
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 10),
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
				}),
			}),
		}),
	})
end

return Shop
