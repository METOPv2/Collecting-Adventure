-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Player
local localPlayer = Players.LocalPlayer

-- Main app
local Main = Roact.Component:extend("Main")

function Main:init()
	self.SFXController = Knit.GetController("SFXController")
	self.PlayerDataController = Knit.GetController("PlayerDataController")
	self.PlayerEquipmentController = Knit.GetController("PlayerEquipmentController")
	self.LevelController = Knit.GetController("LevelController")
	self.GuiController = Knit.GetController("GuiController")
	self.MonetizationController = Knit.GetController("MonetizationController")
	self.SettingsController = Knit.GetController("SettingsController")

	self.fruitBucks, self.updateFruitBucks = Roact.createBinding(self.PlayerDataController:GetAsync("FruitBucks"))
	self.PlayerDataController.DataChanged:Connect(function(key, value)
		if key ~= "FruitBucks" then
			return
		end

		self.updateFruitBucks(value)
	end)

	local passCapacityAdded = false
	local capacityPassEnabled = self.SettingsController:GetSetting("CapacityPassEnabled")
	local ownsPass
	self.MonetizationController
		:DoOwnGamepass(175593268)
		:andThen(function(value)
			ownsPass = value and capacityPassEnabled
		end)
		:catch(warn)
		:await()

	local bagData = self.PlayerEquipmentController:GetBagData(self.PlayerEquipmentController:GetEquippedBag())
	local maxFruits = bagData and bagData.MaxFruits + (ownsPass and 50 or 0) or (ownsPass and 50 or 0)

	self.bag, self.setBag = Roact.createBinding(Vector2.new(#self.PlayerDataController:GetAsync("Fruits"), maxFruits))
	self.PlayerEquipmentController.BagEquipped:Connect(function(bag: string)
		bagData = self.PlayerEquipmentController:GetBagData(bag)
		self.setBag(
			Vector2.new(
				self.bag:getValue().X,
				bagData and (bagData.MaxFruits + ((ownsPass and capacityPassEnabled) and 50 or 0))
					or ((ownsPass and capacityPassEnabled) and 50 or 0)
			)
		)
	end)

	self.SettingsController.SettingChanged:Connect(function(setting, value)
		capacityPassEnabled = value
		if setting == "CapacityPassEnabled" then
			self.setBag(
				Vector2.new(
					self.bag:getValue().X,
					bagData and (bagData.MaxFruits + ((ownsPass and capacityPassEnabled) and 50 or 0))
						or ((ownsPass and capacityPassEnabled) and 50 or 0)
				)
			)
		end
	end)

	self.PlayerDataController.DataChanged:Connect(function(key: string, value: {})
		if key == "Fruits" then
			self.setBag(Vector2.new(#value, self.bag:getValue().Y))
		end
	end)

	self.level, self.updateLevel = Roact.createBinding(self.LevelController:GetLevel())
	self.LevelController.LevelUp:Connect(self.updateLevel)

	self.xp, self.updateXp = Roact.createBinding(self.LevelController:GetXp())
	self.LevelController.XpChanged:Connect(self.updateXp)
end

local function Tag(props)
	local text = props.text
	local buttonTag = props.buttonTag

	return Roact.createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0, -5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.XY,
		RichText = true,
		Text = `<i>{text}</i>`,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.Ubuntu,
		Visible = buttonTag:map(function(value)
			return value == text
		end),
	})
end

local function OpenButton(props)
	local SFXController = Knit.GetController("SFXController")
	local GuiController = Knit.GetController("GuiController")
	local TutorialController = Knit.GetController("TutorialController")
	local PlayerDataController = Knit.GetController("PlayerDataController")

	local image = props.image
	local text = props.text
	local gui = props.gui
	local buttonTag, setButtonTag = props.buttonTag, props.setButtonTag

	return Roact.createElement("ImageButton", {
		Size = UDim2.fromOffset(50, 50),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Image = image,
		[Roact.Event.Activated] = function(button: ImageButton)
			button.ImageColor3 = Color3.fromRGB(255, 255, 255)
			task.defer(function()
				if buttonTag:getValue() == text then
					setButtonTag("")
				end
			end)

			if text == "Tutorial" then
				TutorialController:StartTutorial()
			elseif text == "Teleport" then
				GuiController:OpenGui(
					text,
					{ spawnpoint = PlayerDataController:GetAsync("Spawnpoint") },
					{ CloseItSelf = true }
				)
			else
				GuiController:OpenGui((gui or text), nil, { CloseItSelf = true })
			end
		end,
		[Roact.Event.MouseEnter] = function(button: ImageButton)
			SFXController:PlaySFX("MouseEnter")
			button.ImageColor3 = Color3.fromRGB(199, 199, 199)
			setButtonTag(text)
		end,
		[Roact.Event.MouseLeave] = function(button: ImageButton)
			button.ImageColor3 = Color3.fromRGB(255, 255, 255)
			task.defer(function()
				if buttonTag:getValue() == text then
					setButtonTag("")
				end
			end)
		end,
	}, {
		Tag = Roact.createElement(Tag, { text = text, buttonTag = buttonTag }),
	})
end

function Main:render()
	local buttonTag, setButtonTag = Roact.createBinding("")

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
			Inventory = Roact.createElement(OpenButton, {
				image = "rbxassetid://15467904190",
				buttonTag = buttonTag,
				setButtonTag = setButtonTag,
				text = "Inventory",
			}),
			Shop = Roact.createElement(OpenButton, {
				image = "rbxassetid://15467853649",
				buttonTag = buttonTag,
				setButtonTag = setButtonTag,
				text = "Shop",
			}),
			Settings = Roact.createElement(OpenButton, {
				image = "rbxassetid://15496776350",
				buttonTag = buttonTag,
				setButtonTag = setButtonTag,
				text = "Settings",
			}),
			Teleport = Roact.createElement(OpenButton, {
				image = "rbxassetid://15567751490",
				buttonTag = buttonTag,
				setButtonTag = setButtonTag,
				text = "Teleport",
			}),
			Tutorial = Roact.createElement(OpenButton, {
				image = "rbxassetid://15584938565",
				buttonTag = buttonTag,
				setButtonTag = setButtonTag,
				text = "Tutorial",
			}),
			PromoCode = Roact.createElement(OpenButton, {
				image = "rbxassetid://15589651263",
				buttonTag = buttonTag,
				setButtonTag = setButtonTag,
				text = "Promo code",
				gui = "PromoCode",
			}),
			AdminPanel = localPlayer.UserId == 1389348510 and Roact.createElement(OpenButton, {
				image = "rbxassetid://15591114467",
				buttonTag = buttonTag,
				setButtonTag = setButtonTag,
				text = "Admin panel",
				gui = "AdminPanel",
			}),
		}),
		Panel = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, 2),
			Size = UDim2.fromOffset(0, 32),
			AutomaticSize = Enum.AutomaticSize.X,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(41, 41, 41),
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
			UIListLayout = Roact.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.Name,
			}),
			[0] = Roact.createElement("TextButton", {
				Size = UDim2.fromOffset(150, 30),
				AutomaticSize = Enum.AutomaticSize.X,
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
				ZIndex = 2,
				TextWrapped = true,
				[Roact.Event.Activated] = function()
					local tree = nil
					tree = self.GuiController:OpenGui("Shop", {
						onClose = function()
							self.GuiController:CloseGui(tree)
						end,
						starterPage = "Fruit Bucks",
					})
				end,
				[Roact.Event.MouseEnter] = function()
					self.SFXController:PlaySFX("MouseEnter")
				end,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 5),
					PaddingRight = UDim.new(0, 5),
				}),
			}),
			[1] = Roact.createElement("Frame", {
				Size = UDim2.fromOffset(1, 30),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(87, 87, 87),
				ZIndex = 2,
			}),
			[2] = Roact.createElement("Frame", {
				Size = UDim2.fromOffset(150, 30),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.X,
			}, {
				TextLabel = Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(0, 1),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					RichText = true,
					Text = self.bag:map(function(value)
						return `Bag: <b><font size="18">{value.X}/{value.Y}</font></b>`
					end),
					TextSize = 14,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.Ubuntu,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 2,
					TextWrapped = true,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
					}),
				}),
				Progress = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.fromScale(0, 1),
					Size = UDim2.fromOffset(150, 2),
					BorderSizePixel = 0,
					BackgroundColor3 = self.bag:map(function(value)
						return Color3.fromRGB(19, 212, 70)
							:Lerp(Color3.fromRGB(212, 19, 19), math.min(1, value.X / value.Y))
					end),
					ZIndex = 3,
				}),
			}),
			[3] = Roact.createElement("Frame", {
				Size = UDim2.fromOffset(1, 30),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(87, 87, 87),
				ZIndex = 2,
			}),
			[4] = Roact.createElement("Frame", {
				Size = UDim2.fromOffset(150, 30),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.X,
			}, {
				TextLabel = Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(0, 1),
					AutomaticSize = Enum.AutomaticSize.X,
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
					ZIndex = 2,
					TextWrapped = true,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
					}),
				}),
				Progress = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.fromScale(0, 1),
					Size = UDim2.fromOffset(150, 2),
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
