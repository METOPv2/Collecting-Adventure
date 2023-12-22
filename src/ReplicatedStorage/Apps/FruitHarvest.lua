local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local function BounceCircle(props)
	local position = props.position

	local progress, setProgress = Roact.createBinding(0)

	task.spawn(function()
		repeat
			setProgress(progress:getValue() + task.wait())
		until progress:getValue() >= 1
	end)

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Enabled = true,
	}, {
		Circle = Roact.createElement("Frame", {
			BorderSizePixel = 0,
			BackgroundTransparency = progress,
			Size = progress:map(function(value)
				return UDim2.fromOffset(80 + (value * 150), 80 + (value * 150))
			end),
			Position = position,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
		}),
	})
end

local function FruitHarvest(props)
	local closeGui = props.closeGui
	local signal = props.signal
	local targetTime = props.targetTime

	local camera = workspace.CurrentCamera

	local hoverTime, setHoverTime = Roact.createBinding(0)
	local absoluteSpeedX, absoluteSpeedY = 400, 400
	local speedX, speedY =
		math.random(0, 1) == 1 and absoluteSpeedX or -absoluteSpeedX,
		math.random(0, 1) == 1 and absoluteSpeedY or -absoluteSpeedY
	local circleSize = 100
	local position, setPosition = Roact.createBinding(
		UDim2.fromOffset(
			math.random(0, camera.ViewportSize.X - circleSize),
			math.random(0, camera.ViewportSize.Y - circleSize)
		)
	)

	RunService:BindToRenderStep("FruitHarvest", Enum.RenderPriority.Last.Value, function(deltaTime)
		local mouse = UserInputService:GetMouseLocation()
		local tree
		if position:getValue().X.Offset + (speedX * deltaTime) + circleSize > camera.ViewportSize.X then
			speedX = -absoluteSpeedX
			tree = Roact.mount(
				Roact.createElement(
					BounceCircle,
					{ position = UDim2.fromOffset(camera.ViewportSize.X, position:getValue().Y.Offset) }
				),
				PlayerGui,
				"CircleBounce"
			)
			task.delay(2, function()
				if tree then
					Roact.unmount(tree)
					tree = nil
				end
			end)
		end
		if position:getValue().Y.Offset + (speedY * deltaTime) + circleSize > camera.ViewportSize.Y then
			speedY = -absoluteSpeedY
			tree = Roact.mount(
				Roact.createElement(
					BounceCircle,
					{ position = UDim2.fromOffset(position:getValue().X.Offset, camera.ViewportSize.Y) }
				),
				PlayerGui,
				"CircleBounce"
			)
			task.delay(2, function()
				if tree then
					Roact.unmount(tree)
					tree = nil
				end
			end)
		end
		if position:getValue().X.Offset + (speedX * deltaTime) < 0 then
			speedX = absoluteSpeedX
			tree = Roact.mount(
				Roact.createElement(BounceCircle, { position = UDim2.fromOffset(0, position:getValue().Y.Offset) }),
				PlayerGui,
				"CircleBounce"
			)
			task.delay(2, function()
				if tree then
					Roact.unmount(tree)
					tree = nil
				end
			end)
		end
		if position:getValue().Y.Offset + (speedY * deltaTime) < 0 then
			speedY = absoluteSpeedY
			tree = Roact.mount(
				Roact.createElement(BounceCircle, { position = UDim2.fromOffset(position:getValue().X.Offset, 0) }),
				PlayerGui,
				"CircleBounce"
			)
			task.delay(2, function()
				if tree then
					Roact.unmount(tree)
					tree = nil
				end
			end)
		end
		setPosition(
			UDim2.fromOffset(
				position:getValue().X.Offset + (speedX * deltaTime),
				position:getValue().Y.Offset + (speedY * deltaTime)
			)
		)
		if
			mouse.X > position:getValue().X.Offset
			and mouse.X < position:getValue().X.Offset + circleSize
			and mouse.Y > position:getValue().Y.Offset
			and mouse.Y < position:getValue().Y.Offset + circleSize
		then
			setHoverTime(hoverTime:getValue() + deltaTime)
			if hoverTime:getValue() > targetTime then
				RunService:UnbindFromRenderStep("FruitHarvest")
				signal:Fire()
				closeGui()
				if tree then
					Roact.unmount(tree)
				end
			end
		end
	end)

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
	}, {
		MovingCircle = Roact.createElement("Frame", {
			Size = UDim2.fromOffset(circleSize, circleSize),
			Position = position,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Thickness = hoverTime:map(function(value)
					return 5 * value / targetTime
				end),
				Color = hoverTime:map(function(value)
					return Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), value / targetTime)
				end),
			}),
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			Icon = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(50, 50),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Image = "rbxassetid://15715014883",
				ImageColor3 = Color3.fromRGB(0, 0, 0),
			}),
		}),
		HoverTime = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -10),
			Size = UDim2.fromOffset(200, 50),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			RichText = true,
			Text = hoverTime:map(function(value)
				return tostring(math.round((value / targetTime) * 100)) .. "%"
			end),
			TextSize = 40,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextStrokeTransparency = 0,
			Font = Enum.Font.GothamMedium,
		}),
		Cancel = Roact.createElement("TextButton", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -10, 1, -10),
			Size = UDim2.fromOffset(150, 40),
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			BackgroundTransparency = 0.4,
			Text = "Cancel",
			TextSize = 18,
			BorderSizePixel = 0,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextStrokeTransparency = 0,
			Font = Enum.Font.Ubuntu,
			[Roact.Event.Activated] = function()
				signal:Fire(true)
				closeGui()
				RunService:UnbindFromRenderStep("FruitHarvest")
			end,
		}),
	})
end

return FruitHarvest
