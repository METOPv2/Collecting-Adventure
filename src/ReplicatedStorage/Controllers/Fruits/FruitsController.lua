local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

local FruitAssets: Folder = ReplicatedStorage:WaitForChild("Assets").Fruits
local Camera = workspace.CurrentCamera

local FruitsController = Knit.CreateController({
	Name = "FruitsController",
	FruitHarvested = Signal.new(),
	FruitsSold = Signal.new(),
	Initialized = Signal.new(),
	Initializing = true,
})

function FruitsController:KnitInit()
	self.TreesController = Knit.GetController("TreesController")
	self.FruitsService = Knit.GetService("FruitsService")
	self.NotificationsService = Knit.GetService("NotificationsService")
	self.GuiController = Knit.GetController("GuiController")
	self.CharacterController = Knit.GetController("CharacterController")

	self.FruitsService.FruitsSold:Connect(function(cash)
		self.FruitsSold:Fire(cash)
	end)

	self.FruitsService.FruitHarvested:Connect(function(fruit)
		self.FruitHarvested:Fire(fruit)
	end)

	self.FruitsService
		:GetFruitLevels()
		:andThen(function(levels)
			self.FruitLevels = levels
		end)
		:catch(warn)
		:await()

	self.Initializing = false
	self.Initialized:Fire()
end

function FruitsController:GetFruitLevel(fruit: string): number
	assert(fruit ~= nil, "Fruit is missing or nil.")
	if self.Initializing then
		self.Initialized:Wait()
	end
	return self.FruitLevels[fruit]
end

function FruitsController:GetFruitLevels(): { [string]: number }
	if self.Initializing then
		self.Initialized:Wait()
	end
	return self.FruitLevels
end

function FruitsController:HarvestFruit(fruit: Model, callback: () -> ())
	local fruitHarvestedSignal = Signal.new()
	local enableAllGui = self.GuiController:HideAllGui()
	self.GuiController:SetBillboardGuisEnabled(false)
	ProximityPromptService.Enabled = false
	self.CharacterController:Freeze()
	local fruitData = require(script.Parent.FruitsData)[fruit.Name]
	local previousCFrame = Camera.CFrame
	Camera.CameraType = Enum.CameraType.Scriptable
	local progress = Instance.new("NumberValue")
	progress.Value = 0
	progress.Parent = ReplicatedStorage
	progress.Changed:Connect(function(value)
		Camera.CFrame = previousCFrame:Lerp(
			CFrame.lookAt(
				fruit:GetPivot().Position + fruit:GetExtentsSize() * 2 - Vector3.new(0, fruit:GetExtentsSize().Y / 2, 0),
				fruit:GetPivot().Position
			),
			value
		)
	end)

	local tween = TweenService:Create(
		progress,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Value = 1 }
	)
	tween:Play()
	tween.Completed:Wait()
	progress:Destroy()

	local HighLight = Instance.new("Highlight")
	HighLight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	HighLight.OutlineColor = Color3.fromRGB(0, 0, 0)
	HighLight.OutlineTransparency = 0.5
	HighLight.FillTransparency = 1
	HighLight.Parent = fruit
	self.GuiController:OpenGui(
		"FruitHarvest",
		{ signal = fruitHarvestedSignal, targetTime = fruitData.HarvestTime },
		{ CloseItSelf = true, OpenIfHidden = true }
	)

	fruitHarvestedSignal:Connect(function(cancelled: boolean?)
		HighLight:Destroy()
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CFrame = previousCFrame
		self.CharacterController:Unfreeze()
		enableAllGui()
		self.GuiController:SetBillboardGuisEnabled(true)
		ProximityPromptService.Enabled = true
		fruitHarvestedSignal:Destroy()

		if not cancelled then
			self.FruitsService:AddFruit(fruit.Name)
			callback()
		end
	end)
end

function FruitsController:SpawnFruit(tree: Model, part: Part)
	-- New fruit model
	local fruitData = require(script.Parent.FruitsData)[tree.Name]
	local treeData = self.TreesController:GetTreeData()[tree.Name]
	local fruit: Model = FruitAssets:FindFirstChild(tree.Name):Clone()
	local size: Vector3 = fruit:GetExtentsSize()

	if treeData.FruitsPositionType == "SameAsLog" then
		fruit:PivotTo(part.CFrame)
	else
		fruit:PivotTo(
			part.CFrame
				* CFrame.new(
					math.random(-40, 40) / 100 * (part.Size.X < part.Size.Z and part.Size.X or part.Size.Z),
					-size.Y / 2 - part.Size.Y / 2,
					math.random(-40, 40) / 100 * (part.Size.X > part.Size.Z and part.Size.X or part.Size.Z)
				)
		)
	end

	if treeData.FruitsRotationType == "360" then
		fruit:PivotTo(
			fruit:GetPivot()
				* CFrame.Angles(
					math.rad(math.random() * 360),
					math.rad(math.random() * 360),
					math.rad(math.random() * 360)
				)
		)
	else
		fruit:PivotTo(fruit:GetPivot() * CFrame.Angles(0, math.rad(math.random() * 360), 0))
	end

	fruit.Parent = part.Parent

	-- Initialize proximity prompt
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.ActionText = "Harvest"
	proximityPrompt.ObjectText = fruitData.Name
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.HoldDuration = 0
	proximityPrompt.Triggered:Connect(function(playerWhoTriggered)
		-- Checks
		if
			playerWhoTriggered:DistanceFromCharacter(fruit:GetPivot().Position)
			> proximityPrompt.MaxActivationDistance
		then
			return self.NotificationsService:new(playerWhoTriggered, {
				text = "Come closer to fruit in order to be able to harvest it.",
				title = "You're too far from the fruit",
				duration = 5,
				type = "warn",
			})
		end

		self:HarvestFruit(fruit, function()
			-- ReSpawn fruit
			fruit:Destroy()
			task.delay(15, self.SpawnFruit, self, tree, part)
		end)
	end)
	proximityPrompt.Parent = fruit
end

return FruitsController
