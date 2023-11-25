-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)

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
local function Main()
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
	})
end

return Main
