-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Apps
local InventoryApp = require(ReplicatedStorage:WaitForChild("Source").Apps.Inventory)

-- Inventory app
local inventoryHandle = nil

local function CloseInventory()
	Roact.unmount(inventoryHandle)
	inventoryHandle = nil
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
		OpenInventory = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -10),
			Size = UDim2.fromOffset(50, 50),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Image = "rbxassetid://15447137400",
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
		FruitBucks = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -10, 1, -10),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.XY,
			RichText = true,
			Text = self.fruitBucks:map(function(value)
				return `<stroke thickness="2" color="rgb(51, 74, 50)"><b>Fruit Bucks: <font size="24">{value}</font></b></stroke>`
			end),
			TextSize = 16,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.Ubuntu,
		}),
	})
end

return Main
