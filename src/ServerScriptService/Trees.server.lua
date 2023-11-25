-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Assets
local treesAssets: Folder = ReplicatedStorage.Assets.Trees
local fruitsAssets: Folder = ReplicatedStorage.Assets.Fruits

-- Data bases
local FruitsDataBase = require(ServerStorage.Source.DataBases.Fruits)
local BagsDataBase = require(ServerStorage.Source.DataBases.Bags)

-- Types
type Fruit = {
	Name: string,
}

-- Functions
local function SpawnFruit(tree: Model, part: Part)
	-- Services
	local PlayerDataService = Knit.GetService("PlayerDataService")

	-- New fruit model
	local fruitData = assert(FruitsDataBase[tree.Name], `{tree.Name}'s data not found or doesn't exist.`)
	local fruit: Model = fruitsAssets:FindFirstChild(tree.Name):Clone()
	local size: Vector3 = fruit:GetExtentsSize()
	fruit:PivotTo(
		part.CFrame
			* CFrame.new(
				math.random(-40, 40) / 100 * (part.Size.X < part.Size.Z and part.Size.X or part.Size.Z),
				-size.Y / 2 - part.Size.Y / 2,
				math.random(-40, 40) / 100 * (part.Size.X > part.Size.Z and part.Size.X or part.Size.Z)
			)
			* CFrame.Angles(0, math.rad(math.random() * 360), 0)
	)
	fruit.Parent = part.Parent

	-- Initialize proximity prompt
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.ActionText = "Harvest"
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.HoldDuration = fruitData.HarvestTime
	proximityPrompt.Triggered:Connect(function(playerWhoTriggered)
		-- Checks
		if
			playerWhoTriggered:DistanceFromCharacter(fruit.PrimaryPart.Position)
			> proximityPrompt.MaxActivationDistance
		then
			return
		end

		local playerFruits = PlayerDataService:GetAsync(playerWhoTriggered, "Fruits")
		local playerBag = PlayerDataService:GetAsync(playerWhoTriggered, "EquippedBag")
		local bagData = BagsDataBase[playerBag]
		if playerBag == "" or #playerFruits + 1 > bagData.MaxFruits then
			return
		end

		-- New fruit
		local newFruit: Fruit = {
			Name = fruitData.Name,
			Id = fruitData.Id,
		}

		PlayerDataService:InsertInTableAsync(playerWhoTriggered, "Fruits", newFruit)

		-- Respawn fruit
		fruit:Destroy()
		task.delay(15, coroutine.wrap(SpawnFruit), tree, part)
	end)
	proximityPrompt.Parent = fruit.PrimaryPart
end

local function SpawnTree(treePart: Part)
	-- New tree model
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
		coroutine.wrap(SpawnFruit)(tree, fruitPart)
	end
end

-- Wait knit to load
Knit.OnStart():await()

-- Spawn trees
for _, part: Part in ipairs(workspace.Trees:GetChildren()) do
	coroutine.wrap(SpawnTree)(part)
end
