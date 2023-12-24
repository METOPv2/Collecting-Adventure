-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Player
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- Components
local WindowsComponent = require(ReplicatedStorage:WaitForChild("Source").Components.Window)

local function Toggle(props)
	local SettingsController = Knit.GetController("SettingsController")
	local SFXController = Knit.GetController("SFXController")

	local id = props.id
	local setting = props.setting
	local value = props.value
	local enabled = props.enabled

	local state, updateState = Roact.createBinding(value)

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(48, 48, 48),
		Visible = enabled,
	}, {
		Label = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(0.5, 1),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Text = setting,
			TextSize = 12,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.Ubuntu,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			UIPaddingLayout = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
			}),
		}),
		Toggle = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			BorderSizePixel = 0,
			BackgroundColor3 = state:map(function(newState)
				return newState and Color3.fromRGB(20, 222, 57) or Color3.fromRGB(209, 19, 19)
			end),
			Position = UDim2.new(1, -14, 0.5, 0),
			Size = UDim2.fromOffset(40, 20),
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			Circle = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = state:map(function(newState)
					return newState and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
				end),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(16, 16),
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			}),
			Button = Roact.createElement("TextButton", {
				Size = UDim2.fromScale(1, 1),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Text = "",
				[Roact.Event.Activated] = function()
					SettingsController:SetSetting(id, not state:getValue())
					updateState(not state:getValue())
				end,
				[Roact.Event.MouseEnter] = function()
					SFXController:PlaySFX("MouseEnter")
				end,
			}),
		}),
	})
end

local Slider = Roact.Component:extend("Slider")

function Slider:init()
	self.connections = {}
end

function Slider:render()
	local SettingsController = Knit.GetController("SettingsController")

	local id = self.props.id
	local setting = self.props.setting
	local value = self.props.value

	local progress, updateProgress = Roact.createBinding(math.clamp(value / 5, 0, 1))
	local mouseHolding, setMouseHolding = Roact.createBinding(false)
	local pointAbsolutePosition, setPointAbsolutePosition = Roact.createBinding(0)
	local pointAbsoluteSize, setPointAbsoluteSize = Roact.createBinding(0)

	table.insert(
		self.connections,
		mouse.Move:Connect(function()
			if mouseHolding:getValue() then
				updateProgress(
					math.clamp((mouse.X - pointAbsolutePosition:getValue()) / pointAbsoluteSize:getValue(), 0, 1)
				)
			end
		end)
	)

	table.insert(
		self.connections,
		mouse.Button1Up:Connect(function()
			SettingsController:SetSetting(id, math.round((progress:getValue() * 5) * 1000) / 1000)
			setMouseHolding(false)
		end)
	)

	return Roact.createElement("Frame", {
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Color3.fromRGB(48, 48, 48),
	}, {
		Label = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(0.5, 1),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Text = setting,
			TextSize = 12,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.Ubuntu,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			UIPaddingLayout = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
			}),
		}),
		Progress = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -14, 0.5, 0),
			Size = UDim2.new(0.5, -14, 0, 5),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(32, 32, 32),
		}, {
			Fill = Roact.createElement("Frame", {
				Size = progress:map(function(newProgress)
					return UDim2.fromScale(newProgress, 1)
				end),
				BorderSizePixel = 0,
				BackgroundColor3 = progress:map(function(newProgress)
					return Color3.fromRGB(222, 27, 27):Lerp(Color3.fromRGB(104, 242, 29), newProgress)
				end),
			}),
			Point = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = progress:map(function(newProgress)
					return UDim2.fromScale(newProgress, 0.5)
				end),
				Size = UDim2.fromOffset(5, 15),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 2,
			}),
		}),
		TriggerZone = Roact.createElement("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			Size = UDim2.new(0.5, -8, 1, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 3,
			[Roact.Event.MouseButton1Down] = function()
				setMouseHolding(true)
				updateProgress(
					math.clamp((mouse.X - pointAbsolutePosition:getValue()) / pointAbsoluteSize:getValue(), 0, 1)
				)
			end,
			[Roact.Event.MouseButton1Up] = function()
				SettingsController:SetSetting(id, math.round((progress:getValue() * 5) * 1000) / 1000)
				setMouseHolding(false)
			end,
			[Roact.Change.AbsoluteSize] = function(object: Frame)
				setPointAbsoluteSize(object.AbsoluteSize.X)
			end,
			[Roact.Change.AbsolutePosition] = function(object: Frame)
				setPointAbsolutePosition(object.AbsolutePosition.X)
			end,
		}),
	})
end

function Slider:willUnmount()
	for i, v: RBXScriptConnection in ipairs(self.connections) do
		v:Disconnect()
		self.connections[i] = nil
	end

	self.connections = nil
end

local function SettingsContent()
	local MonetizationController = Knit.GetController("MonetizationController")
	local SettingsController = Knit.GetController("SettingsController")
	local _elements = {}
	local tabs = {
		Music = {
			"MusicEnabled",
			"MusicVolume",
		},
		SFX = {
			"SFXEnabled",
			"SFXVolume",
		},
		Notifications = {
			"NotificationsEnabled",
			"WelcomeBackNotification",
		},
		GUI = {
			"OpenUpdateLogOnStart",
		},
		Passes = {
			"CapacityPassEnabled",
			"WalkSpeedPassEnabled",
			"FruitPricePassEnabled",
		},
		Performance = {
			"LowPerformanceMode",
		},
	}
	local ids = {
		CapacityPassEnabled = 175593268,
		WalkSpeedPassEnabled = 175593072,
		FruitPricePassEnabled = 175594858,
	}

	for tab, content in pairs(tabs) do
		local tabContent = {}

		for _, v in ipairs(content) do
			if typeof(SettingsController:GetSetting(v)) == "boolean" then
				local enabled, setEnabled = Roact.createBinding(true)
				if ids[v] then
					MonetizationController:DoOwnGamepass(ids[v])
						:andThen(function(owns)
							setEnabled(owns)
						end)
						:catch(warn)
				end
				table.insert(
					tabContent,
					Roact.createElement(Toggle, {
						setting = SettingsController:GetSettingName(v),
						id = v,
						value = SettingsController:GetSetting(v),
						enabled = enabled,
					})
				)
			elseif typeof(SettingsController:GetSetting(v)) == "number" then
				table.insert(
					tabContent,
					Roact.createElement(Slider, {
						setting = SettingsController:GetSettingName(v),
						id = v,
						value = SettingsController:GetSetting(v),
					})
				)
			end
		end

		local new = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 30),
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		}, {
			Label = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 30),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = tab,
				RichText = true,
				TextSize = 16,
				FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold),
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 10),
				}),
			}),
			Frame = Roact.createElement("Frame", {
				Position = UDim2.fromOffset(0, 30),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				Content = Roact.createFragment(tabContent),
				UIListLayout = Roact.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 1),
				}),
			}),
		})
		if new then
			table.insert(_elements, new)
		end
	end

	return Roact.createFragment(_elements)
end

-- Settings app
local function Settings(props)
	local closeGui = props.closeGui

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		Contrainer = Roact.createElement(WindowsComponent, {
			title = "Settings",
			size = UDim2.fromOffset(400, 300),
			closeGui = closeGui,
		}, {
			Container = Roact.createElement("ScrollingFrame", {
				Size = UDim2.fromScale(1, 1),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				CanvasSize = UDim2.fromOffset(0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 5,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					Padding = UDim.new(0, 10),
				}),
				Content = Roact.createElement(SettingsContent),
			}),
		}),
	})
end

return Settings
