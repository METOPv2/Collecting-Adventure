-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Assets
local fruitsAssets = ReplicatedStorage:WaitForChild("Assets").Fruits
local bagsAssets = ReplicatedStorage:WaitForChild("Assets").Bags

-- Components
local WindowComponent = require(ReplicatedStorage:WaitForChild("Source").Components.Window)

local function FruitInfo(props)
	local fruit = props.fruit
	local hovering = props.hovering
	local _elements = {}
	local whiteList = { "Name", "Harvested" }

	local index = 0
	for key, value in pairs(fruit) do
		index += 1
		if not table.find(whiteList, key) then
			continue
		end
		local valueBinding, setValue = Roact.createBinding(value)
		if key == "Harvested" then
			setValue(`{math.round(workspace:GetServerTimeNow() - value)} s. ago`)
		end
		local new = Roact.createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 20),
			BackgroundColor3 = (index % 2 == 0 and Color3.fromRGB(39, 39, 39) or Color3.fromRGB(104, 104, 104)),
			BorderSizePixel = 0,
			RichText = true,
			Text = valueBinding:map(function(text)
				return string.format("%s: %s", key, text)
			end),
			TextSize = 12,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.Ubuntu,
			TextXAlignment = Enum.TextXAlignment.Left,
			Visible = hovering:map(function(enabled)
				if enabled then
					if key == "Harvested" then
						coroutine.wrap(function()
							while hovering:getValue() do
								setValue(`{math.round(workspace:GetServerTimeNow() - value)} s. ago`)
								task.wait()
							end
						end)()
					else
						setValue(value)
					end
				end
				return enabled
			end),
			ZIndex = 3,
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
			}),
			UISizeConstraint = Roact.createElement("UISizeConstraint", {
				MinSize = Vector2.new(75, 0),
			}),
		})
		table.insert(_elements, new)
	end

	return Roact.createFragment(_elements)
end

local function Fruit(props)
	local cameraRef = Roact.createRef()
	local fruit: {} = props.fruit
	local model: Model = fruitsAssets:FindFirstChild(fruit.Name):Clone()
	local size: Vector3 = model:GetExtentsSize()
	local pivot: CFrame = model:GetPivot()

	local hovering, setHovering = Roact.createBinding(false)

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
		ViewportFrame = Roact.createElement("ViewportFrame", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			CurrentCamera = cameraRef,
			LightColor = Color3.fromRGB(255, 255, 255),
			ZIndex = 2,
			[Roact.Event.MouseEnter] = function()
				setHovering(true)
			end,
			[Roact.Event.MouseLeave] = function()
				setHovering(false)
			end,
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
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.Name,
			}),
			FruitInfo = Roact.createElement(FruitInfo, { fruit = fruit, hovering = hovering }),
		}),
	})
end

local function Fruits(props)
	local elements = {}

	for _, fruit in ipairs(props.fruits) do
		table.insert(elements, Roact.createElement(Fruit, { fruit = fruit }))
	end

	return Roact.createFragment(elements)
end

local function Tab(props)
	local SFXController = Knit.GetController("SFXController")

	local text = props.text
	local active = props.active
	local changeActive = props.changeActive

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 20),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = active:map(function(value)
				return value == text and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(167, 167, 167)
			end),
		}),
		Button = Roact.createElement("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Text = text,
			TextSize = 12,
			TextColor3 = active:map(function(value)
				return value == text and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(167, 167, 167)
			end),
			Font = Enum.Font.Ubuntu,
			[Roact.Event.Activated] = function()
				changeActive(text)
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
	local active = props.active
	local changeActive = props.changeActive
	local elements = {}

	for _, tab in ipairs(tabs) do
		table.insert(
			elements,
			Roact.createElement(Tab, {
				text = tab,
				active = active,
				changeActive = changeActive,
			})
		)
	end

	return Roact.createFragment(elements)
end

local function Bag(props)
	local SFXController = Knit.GetController("SFXController")
	local PlayerEquipmentController = Knit.GetController("PlayerEquipmentController")

	local bag = props.bag
	local equipped = props.equipped
	local updateEquip = props.updateEquip
	local model: Model = bagsAssets:FindFirstChild(bag):Clone()
	local size: Vector3 = model:GetExtentsSize()
	local pivot: CFrame = model:GetPivot()
	local cameraRef = Roact.createRef()

	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(46, 46, 46),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(50, 50),
	}, {
		UIStroke = Roact.createElement("UIStroke", {
			Color = equipped:map(function(value)
				return value == bag and Color3.fromRGB(0, 225, 0) or Color3.fromRGB(119, 119, 119)
			end),
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
				local isEquipped: boolean = PlayerEquipmentController:IsBagEquipped(bag)
				PlayerEquipmentController:EquipBag(isEquipped and "" or bag)
				updateEquip(isEquipped and "" or bag)
			end,
			[Roact.Event.MouseEnter] = function()
				SFXController:PlaySFX("MouseEnter")
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
	})
end

local function Bags(props)
	local elements = {}

	local equipped, updateEquip = Roact.createBinding(props.equippedBag)

	for _, bag in pairs(props.bags) do
		table.insert(elements, Roact.createElement(Bag, { bag = bag, equipped = equipped, updateEquip = updateEquip }))
	end

	return Roact.createFragment(elements)
end

local function Holder(props)
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = props.currentTab:map(function(value)
			return value == props.name
		end),
	}, {
		Holder = Roact.createElement("ScrollingFrame", {
			Size = UDim2.new(1, -10, 1, -10),
			Position = UDim2.fromOffset(5, 5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 5,
			ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			CanvasSize = UDim2.fromOffset(0, 0),
			ClipsDescendants = false,
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 1),
				PaddingLeft = UDim.new(0, 1),
				PaddingRight = UDim.new(0, 1),
				PaddingTop = UDim.new(0, 1),
			}),
			UIGridLayout = Roact.createElement("UIGridLayout", {
				CellSize = UDim2.fromOffset(50, 50),
				CellPadding = UDim2.fromOffset(5, 5),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
			Items = props.itemsElement,
		}),
		NoBags = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Text = props.noItemsMessage,
			TextSize = 16,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.Ubuntu,
			Visible = #props.items == 0,
		}),
	})
end

-- Inventory app
local Inventory = Roact.Component:extend("Inventory")

function Inventory:init()
	self.PlayerDataController = Knit.GetController("PlayerDataController")
	self.PlayerEquipmentController = Knit.GetController("PlayerEquipmentController")

	self:setState({
		fruits = self.PlayerDataController:GetAsync("Fruits"),
		bags = self.PlayerDataController:GetAsync("Bags"),
	})

	self.connection = self.PlayerDataController.DataChanged:Connect(function(key: any, value: any)
		if key == "Fruits" then
			self:setState({ fruits = value })
		elseif key == "Bags" then
			self:setState({ bags = value })
		end
	end)
end

function Inventory:render()
	local closeGui = self.props.closeGui
	local starterPage = self.props.starterPage or "Fruits"

	local currentTab, updateCurrentTab = Roact.createBinding(starterPage)

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		Contrainer = Roact.createElement(WindowComponent, {
			title = "Inventory",
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
				}),
				Tabs = Roact.createElement(
					Tabs,
					{ tabs = { "Fruits", "Bags" }, active = currentTab, changeActive = updateCurrentTab }
				),
			}),
			Contrainer = Roact.createElement("Frame", {
				Position = UDim2.fromOffset(150, 0),
				Size = UDim2.new(1, -150, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				Bags = Roact.createElement(Holder, {
					name = "Bags",
					currentTab = currentTab,
					noItemsMessage = "Currently, you have no bags.",
					items = self.state.bags,
					itemsElement = Roact.createElement(Bags, {
						bags = self.state.bags,
						equippedBag = self.PlayerEquipmentController:GetEquippedBag(),
					}),
				}),
				Fruits = Roact.createElement(Holder, {
					name = "Fruits",
					currentTab = currentTab,
					noItemsMessage = "Currently, you have no fruits.",
					items = self.state.fruits,
					itemsElement = Roact.createElement(Fruits, { fruits = self.state.fruits }),
				}),
			}),
		}),
	})
end

function Inventory:willUnmount()
	self.connection:Disconnect()
end

return Inventory
