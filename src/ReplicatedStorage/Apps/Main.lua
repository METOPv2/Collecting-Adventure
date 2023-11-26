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
	self.LevelController = Knit.GetController("LevelController")

	self.fruitBucks, self.updateFruitBucks = Roact.createBinding(self.PlayerDataController:GetAsync("FruitBucks"))
	self.PlayerDataController.DataChanged:Connect(function(key, value)
		if key ~= "FruitBucks" then
			return
		end

		self.updateFruitBucks(value)
	end)

	self.level, self.updateLevel = Roact.createBinding(self.LevelController:GetLevel())
	self.LevelController.LevelUp:Connect(self.updateLevel)

	self.xp, self.updateXp = Roact.createBinding(self.LevelController:GetXp())
	self.LevelController.XpChanged:Connect(self.updateXp)
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
		Panel = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromOffset(250, 30),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(41, 41, 41),
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			Line = Roact.createElement("Frame", {
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.new(0, 1, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(87, 87, 87),
				ZIndex = 2,
			}),
			Fill = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.5),
				Position = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(41, 41, 41),
			}),
			FruitBucks = Roact.createElement("Frame", {
				Size = UDim2.fromScale(0.5, 1),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
			}, {
				TextLabel = Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					RichText = true,
					Text = self.fruitBucks:map(function(value)
						return `Fruit Bucks: <b><font size="18">{value}</font></b>`
					end),
					TextSize = 14,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.Ubuntu,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 3,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 8),
					}),
				}),
				Button = Roact.createElement("TextButton", {
					Size = UDim2.fromScale(1, 1),
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					Text = "",
					[Roact.Event.Activated] = function()
						if shopHandle then
							return CloseShop()
						end

						local element =
							Roact.createElement(ShopApp, { starterPage = "Fruit Bucks", onClose = CloseShop })
						shopHandle = Roact.mount(element, playerGui, "Shop")
					end,
				}),
			}),
			Level = Roact.createElement("Frame", {
				Size = UDim2.fromScale(0.5, 1),
				Position = UDim2.fromScale(0.5, 0),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
			}, {
				TextLabel = Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					RichText = true,
					Text = self.level:map(function(value)
						return `Level: <b><font size="18">{value}</font></b>`
					end),
					TextSize = 14,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.Ubuntu,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 3,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 8),
					}),
				}),
				Progress = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.fromScale(0, 1),
					Size = UDim2.new(1, 0, 0, 2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(167, 167, 167),
					ZIndex = 3,
					Visible = self.xp:map(function(xp)
						return xp ~= 0
					end),
				}, {
					Line = Roact.createElement("Frame", {
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(62, 184, 236),
						Size = self.xp:map(function(xp)
							return UDim2.fromScale(
								math.min(1, xp / self.LevelController:CalculateXpGoal(self.level:getValue())),
								1
							)
						end),
						ZIndex = 4,
					}),
				}),
			}),
		}),
	})
end

return Main
