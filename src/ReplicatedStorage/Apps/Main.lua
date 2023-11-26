-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Apps
local InventoryApp = require(ReplicatedStorage:WaitForChild("Source").Apps.Inventory)
local ShopApp = require(ReplicatedStorage:WaitForChild("Source").Apps.Shop)

-- Inventory app
local inventoryHandle = nil

local function CloseInventory()
	Roact.unmount(inventoryHandle)
	inventoryHandle = nil
end

-- Shop app
local shopHandle = nil

local function CloseShop()
	Roact.unmount(shopHandle)
	shopHandle = nil
end

-- Player
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Main app
local Main = Roact.Component:extend("Main")

function Main:init()
	self.PlayerDataController = Knit.GetController("PlayerDataController")

	self.fruitBucks, self.updateFruitBucks = Roact.createBinding(self.PlayerDataController:GetAsync("FruitBucks"))

	self.PlayerDataController.DataChanged:Connect(function(key, value)
		if key ~= "FruitBucks" then
			return
		end

		self.updateFruitBucks(value)
	end)
end

function Main:render()
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		Buttons = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -40),
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 50),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 10),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			OpenInventory = Roact.createElement("ImageButton", {
				Size = UDim2.fromOffset(50, 50),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Image = "rbxassetid://15467904190",
				[Roact.Event.Activated] = function()
					if inventoryHandle then
						return CloseInventory()
					end

					local element = Roact.createElement(InventoryApp, { onClose = CloseInventory })
					inventoryHandle = Roact.mount(element, playerGui, "Inventory")
				end,
				[Roact.Event.MouseEnter] = function(button: ImageButton)
					button.ImageColor3 = Color3.fromRGB(199, 199, 199)
				end,
				[Roact.Event.MouseLeave] = function(button: ImageButton)
					button.ImageColor3 = Color3.fromRGB(255, 255, 255)
				end,
			}),
			OpenShop = Roact.createElement("ImageButton", {
				Size = UDim2.fromOffset(50, 50),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Image = "rbxassetid://15467853649",
				[Roact.Event.Activated] = function()
					if shopHandle then
						return CloseShop()
					end

					local element = Roact.createElement(ShopApp, { onClose = CloseShop })
					shopHandle = Roact.mount(element, playerGui, "Shop")
				end,
				[Roact.Event.MouseEnter] = function(button: ImageButton)
					button.ImageColor3 = Color3.fromRGB(199, 199, 199)
				end,
				[Roact.Event.MouseLeave] = function(button: ImageButton)
					button.ImageColor3 = Color3.fromRGB(255, 255, 255)
				end,
			}),
		}),
		FruitBucks = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromOffset(200, 30),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(41, 41, 41),
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			Frame = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 0.5),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(41, 41, 41),
			}),
			TextLabel = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				RichText = true,
				Text = self.fruitBucks:map(function(value)
					return `<b>Fruit Bucks: <font size="18">{value}</font></b>`
				end),
				TextSize = 14,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.Ubuntu,
				ZIndex = 2,
			}),
		}),
	})
end

return Main
