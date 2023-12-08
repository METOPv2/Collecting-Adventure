-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Main app
local Main = Roact.Component:extend("Main")

function Main:init()
	self.SFXController = Knit.GetController("SFXController")
	self.PlayerDataController = Knit.GetController("PlayerDataController")
	self.PlayerEquipmentController = Knit.GetController("PlayerEquipmentController")
	self.LevelController = Knit.GetController("LevelController")
	self.GuiController = Knit.GetController("GuiController")

	self.fruitBucks, self.updateFruitBucks = Roact.createBinding(self.PlayerDataController:GetAsync("FruitBucks"))
	self.PlayerDataController.DataChanged:Connect(function(key, value)
		if key ~= "FruitBucks" then
			return
		end

		self.updateFruitBucks(value)
	end)

	local bagData = self.PlayerEquipmentController:GetBagData(self.PlayerEquipmentController:GetEquippedBag())
	local maxFruits = bagData and bagData.MaxFruits or 0

	self.bag, self.setBag = Roact.createBinding(Vector2.new(#self.PlayerDataController:GetAsync("Fruits"), maxFruits))
	self.PlayerEquipmentController.BagEquipped:Connect(function(bag: string)
		self.setBag(Vector2.new(self.bag:getValue().X, self.PlayerEquipmentController:GetBagData(bag).MaxFruits or 0))
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

	local image = props.image
	local text = props.text
	local buttonTag, setButtonTag = props.buttonTag, props.setButtonTag

	return Roact.createElement("ImageButton", {
		Size = UDim2.fromOffset(50, 50),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Image = image,
		[Roact.Event.Activated] = function()
			GuiController:OpenGui(text, nil, { CloseItSelf = true })
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
		}),
		Panel = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromOffset(450, 30),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(41, 41, 41),
		}, {
			Fill = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.5),
				Position = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0.5, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(41, 41, 41),
			}),
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			FruitBucks = Roact.createElement("Frame", {
				Size = UDim2.new(0, 150, 1, 0),
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
						PaddingLeft = UDim.new(0, 5),
					}),
				}),
				Button = Roact.createElement("TextButton", {
					Size = UDim2.fromScale(1, 1),
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					Text = "",
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
				}),
			}),
			FirstLine = Roact.createElement("Frame", {
				Position = UDim2.fromOffset(150, 0),
				Size = UDim2.new(0, 1, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(87, 87, 87),
				ZIndex = 2,
			}),
			Bag = Roact.createElement("Frame", {
				Size = UDim2.new(0, 150, 1, 0),
				Position = UDim2.fromOffset(150, 0),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
			}, {
				TextLabel = Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(1, 1),
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
					BackgroundColor3 = self.bag:map(function(value)
						return Color3.fromRGB(19, 212, 70)
							:Lerp(Color3.fromRGB(212, 19, 19), math.min(1, value.X / value.Y))
					end),
					ZIndex = 3,
				}),
			}),
			SecondLine = Roact.createElement("Frame", {
				Position = UDim2.fromOffset(300, 0),
				Size = UDim2.new(0, 1, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(87, 87, 87),
				ZIndex = 2,
			}),
			Level = Roact.createElement("Frame", {
				Size = UDim2.new(0, 150, 1, 0),
				Position = UDim2.fromOffset(300, 0),
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
