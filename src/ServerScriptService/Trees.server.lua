-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Assets
local treesAssets: Folder = ReplicatedStorage.Assets.Trees
local fruitsAssets: Folder = ReplicatedStorage.Assets.Fruits

-- Data bases
local TreesDataBase = require(ServerStorage.Source.DataBases.Trees)
local FruitsDataBase = require(ServerStorage.Source.DataBases.Fruits)

-- Functions
local function SpawnFruit(tree: Model, part: Part)
	-- Services
	local NotificationsService = Knit.GetService("NotificationsService")
	local FruitsService = Knit.GetService("FruitsService")

	-- New fruit model
	local fruitData = assert(FruitsDataBase[tree.Name], `{tree.Name}'s data not found or doesn't exist.`)
	local treeData = TreesDataBase[tree.Name]
	local fruit: Model = fruitsAssets:FindFirstChild(tree.Name):Clone()
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
	proximityPrompt.HoldDuration = fruitData.HarvestTime
	proximityPrompt.Triggered:Connect(function(playerWhoTriggered)
		-- Checks
		if
			playerWhoTriggered:DistanceFromCharacter(fruit:GetPivot().Position)
			> proximityPrompt.MaxActivationDistance
		then
			return NotificationsService:new(playerWhoTriggered, {
				text = "Come closer to fruit in order to be able to harvest it.",
				title = "You're too far from the fruit",
				duration = 5,
				type = "warn",
			})
		end

		FruitsService:AddFruit(playerWhoTriggered, tree.Name)

		-- Respawn fruit
		fruit:Destroy()
		task.delay(15, coroutine.wrap(SpawnFruit), tree, part)
	end)
	proximityPrompt.Parent = fruit
end

local function SpawnTree(treePart: Part)
	-- New tree model
	local treeData: TreesDataBase.DataBase =
		assert(TreesDataBase[treePart.Name], `{treePart.Name}'s data doesn't exist.`)
	local tree: Model = treesAssets:FindFirstChild(treePart.Name):Clone()
	local size: Vector3 = tree:GetExtentsSize()
	tree:PivotTo(
		treePart.CFrame
			* CFrame.new(0, size.Y / 2 - treePart.Size.Y / 2, 0)
			* CFrame.Angles(0, math.rad(math.random() * 360), 0)
	)
	tree.Parent = treePart.Parent

	-- Remove part
	treePart:Destroy()

	-- Spawn fruits
	for _, fruitPart: Part in ipairs(tree.Fruits:GetChildren()) do
		for _ = 1, treeData.FruitsPerLog do
			coroutine.wrap(SpawnFruit)(tree, fruitPart)
		end
	end
end

-- Wait knit to load
Knit.OnStart():await()

-- Spawn trees
for _, part: Part in ipairs(workspace.Trees:GetChildren()) do
	local found = false
	for _, v in ipairs(workspace.Trees:GetChildren()) do
		if v.ClassName == "Folder" and v.Name == part.Name then
			found = v
			break
		end
	end
	if not found then
		found = Instance.new("Folder")
		found.Name = part.Name
		found.Parent = workspace.Trees
	end
	part.Parent = found
	coroutine.wrap(SpawnTree)(part)
end
