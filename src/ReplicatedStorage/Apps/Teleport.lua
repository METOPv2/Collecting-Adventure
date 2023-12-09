-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Components
local WindowComponent = require(ReplicatedStorage:WaitForChild("Source").Components.Window)

local function Button(props)
	local SFXController = Knit.GetController("SFXController")
	local TeleportController = Knit.GetController("TeleportController")
	local FruitsController = Knit.GetController("FruitsController")

	local spawnpoint = props.spawnpoint
	local index = props.index

	local activeTab, setActiveTab = props.activeTab, props.setActiveTab
	local closeGui = props.closeGui

	return Roact.createElement("TextButton", {
		Size = UDim2.new(1, 0, 0, 20),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(44, 44, 44),
		Text = `{index}: {spawnpoint} (Level {FruitsController:GetFruitLevel(spawnpoint)})`,
		[Roact.Event.Activated] = function()
			TeleportController:Teleport(spawnpoint)
			setActiveTab(spawnpoint)
			closeGui()
		end,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.Ubuntu,
		[Roact.Event.MouseEnter] = function()
			SFXController:PlaySFX("MouseEnter")
		end,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, {
		UIPadding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
		}),
		UIcorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = activeTab:map(function(value)
				return value == spawnpoint and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(117, 117, 117)
			end),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),
	})
end

local function Buttons(props)
	local TeleportController = Knit.GetController("TeleportController")
	local buttons = {}
	local spawnpoints = TeleportController:GetSpawnpoints()
	local spawnpoint = props.spawnpoint
	local closeGui = props.closeGui
	local activeTab, setActiveTab = Roact.createBinding(spawnpoint)

	for i, spawnpoint in ipairs(spawnpoints) do
		table.insert(
			buttons,
			Roact.createElement(Button, {
				index = i,
				activeTab = activeTab,
				setActiveTab = setActiveTab,
				spawnpoint = spawnpoint,
				closeGui = closeGui,
			})
		)
	end

	return Roact.createFragment(buttons)
end

-- Teleport app
local function Teleport(props)
	local closeGui = props.closeGui
	local spawnpoint = props.spawnpoint
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		Contrainer = Roact.createElement(WindowComponent, {
			size = UDim2.fromOffset(400, 300),
			title = "Teleport",
			closeGui = closeGui,
		}, {
			Holder = Roact.createElement("ScrollingFrame", {
				Size = UDim2.fromScale(1, 1),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				CanvasSize = UDim2.fromOffset(0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 5,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 5),
					PaddingRight = UDim.new(0, 5),
					PaddingTop = UDim.new(0, 5),
					PaddingBottom = UDim.new(0, 5),
				}),
				UIListLayout = Roact.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					Padding = UDim.new(0, 10),
					FillDirection = Enum.FillDirection.Vertical,
				}),
				Buttons = Roact.createElement(Buttons, { spawnpoint = spawnpoint, closeGui = closeGui }),
			}),
		}),
	})
end

return Teleport
