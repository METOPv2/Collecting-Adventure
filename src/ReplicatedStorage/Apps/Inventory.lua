-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Assets
local fruitsAssets = ReplicatedStorage:WaitForChild("Assets").Fruits

-- Components
local WindowComponent = require(ReplicatedStorage:WaitForChild("Source").Components.Window)

local function Fruit(props)
	local fruit = props.fruit
	local cameraRef = Roact.createRef()

	local model: Model = fruitsAssets:FindFirstChild(fruit.Name):Clone()
	local size = model:GetExtentsSize()

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
		}, {
			Camera = Roact.createElement("Camera", {
				CFrame = CFrame.lookAt(model:GetPivot().Position + size, model:GetPivot().Position),
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

local function Fruits(props)
	local fruits = props.fruits
	local elements = {}

	for _, fruit in ipairs(fruits) do
		table.insert(elements, Roact.createElement(Fruit, { fruit = fruit }))
	end

	return Roact.createFragment(elements)
end

-- Inventory app
local Inventory = Roact.Component:extend("Inventory")

function Inventory:init()
	self.PlayerDataController = Knit.GetController("PlayerDataController")
	self:setState({ fruits = self.PlayerDataController:GetAsync("Inventory") })
	self.connection = self.PlayerDataController.DataChanged:Connect(function(key: any, value: any)
		if key ~= "Inventory" then
			return
		end

		self:setState({ fruits = value })
	end)
end

function Inventory:render()
	local onClose = self.props.onClose

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		Contrainer = Roact.createElement(WindowComponent, {
			title = "Inventory",
			size = UDim2.fromOffset(400, 300),
			onClose = onClose,
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
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingBottom = UDim.new(0, 1),
					PaddingLeft = UDim.new(0, 1),
					PaddingRight = UDim.new(0, 1),
					PaddingTop = UDim.new(0, 1),
				}),
				UIListLayout = Roact.createElement("UIListLayout", {
					Wraps = true,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 5),
				}),
				Fruits = Roact.createElement(Fruits, { fruits = self.state.fruits }),
			}),
			CollectFruits = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Text = "Currently, you have no fruits.",
				TextSize = 16,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.Ubuntu,
				Visible = #self.state.fruits == 0,
			}),
		}),
	})
end

function Inventory:willUnmount()
	self.connection:Disconnect()
end

return Inventory
