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
local BagsDataBase = require(ServerStorage.Source.DataBases.Bags)

-- Types
type Fruit = {
	Name: string,
}

-- Functions
local function SpawnFruit(tree: Model, part: Part)
	-- Services
	local PlayerDataService = Knit.GetService("PlayerDataService")
	local LevelService = Knit.GetService("LevelService")
	local NotificationsService = Knit.GetService("NotificationsService")
	local SFXService = Knit.GetService("SFXService")
	local GuiService = Knit.GetService("GuiService")
	local MarkerService = Knit.GetService("MarkerService")

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

		local playerFruits = PlayerDataService:GetAsync(playerWhoTriggered, "Fruits")
		local playerBag = PlayerDataService:GetAsync(playerWhoTriggered, "EquippedBag")
		local bagData = BagsDataBase[playerBag]

		if playerBag == "" then
			GuiService:OpenGui(
				playerWhoTriggered,
				"Inventory",
				{ starterPage = "Bags" },
				{ CloseItSelf = true, DontCloseIfAlreadyOpen = true }
			)

			return NotificationsService:new(playerWhoTriggered, {
				text = "You are unable to harvest fruits without an equipped bag. Consider equipping it from your inventory.",
				title = "No bag is equipped",
				duration = 15,
				type = "warn",
			})
		end

		if playerBag == "" or #playerFruits + 1 > bagData.MaxFruits then
			MarkerService:New(playerWhoTriggered, workspace.SellParts, { Key = "Sell" })

			return NotificationsService:new(playerWhoTriggered, {
				text = "Sell your current fruits to have more capacity in your bag.",
				title = "Max fruits reached",
				duration = 15,
				type = "warn",
			})
		end

		if LevelService:GetLevel(playerWhoTriggered) < fruitData.Level then
			return NotificationsService:new(playerWhoTriggered, {
				text = `Your current level is {LevelService:GetLevel(playerWhoTriggered)}, and you can't harvest fruit which requires {fruitData.Level - LevelService:GetLevel(
					playerWhoTriggered
				)} more level{fruitData.Level > 1 and "s" or ""}.`,
				title = "Level is too high",
				duration = 15,
				type = "warn",
			})
		end

		-- New fruit
		local newFruit: Fruit = {
			Name = fruitData.Name,
			Id = fruitData.Id,
		}

		LevelService:IncrementXp(playerWhoTriggered, fruitData.Xp)
		PlayerDataService:InsertInTableAsync(playerWhoTriggered, "Fruits", newFruit)

		-- Play SFX
		SFXService:PlayLocalSFX(playerWhoTriggered, "Pop")

		-- Check if bag is already full
		if playerBag == "" or #PlayerDataService:GetAsync(playerWhoTriggered, "Fruits") >= bagData.MaxFruits then
			MarkerService:New(playerWhoTriggered, workspace.SellParts, { Key = "Sell" })

			return NotificationsService:new(playerWhoTriggered, {
				text = "Sell your current fruits to have more capacity in your bag.",
				title = "Max fruits reached",
				duration = 15,
				type = "warn",
			})
		end

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
	coroutine.wrap(SpawnTree)(part)
end
