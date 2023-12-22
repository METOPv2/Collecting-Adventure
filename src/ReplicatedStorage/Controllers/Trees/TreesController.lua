local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local TreeAssets: Folder = ReplicatedStorage:WaitForChild("Assets"):FindFirstChild("Trees")
local TreesController = Knit.CreateController({
	Name = "TreesController",
})

function TreesController:KnitInit()
	self.FruitsController = Knit.GetController("FruitsController")
end

function TreesController:KnitStart()
	local Trees = workspace:WaitForChild("Trees")
	for _, part: Part in ipairs(Trees:GetChildren()) do
		local found = false
		for _, v in ipairs(Trees:GetChildren()) do
			if v.ClassName == "Folder" and v.Name == part.Name and not found then
				found = v
			end
		end
		if not found then
			found = Instance.new("Folder")
			found.Name = part.Name
			found.Parent = Trees
		end
		part.Parent = found
		self:SpawnTree(part)
	end
	Trees.ChildAdded:Connect(function(TreePosition)
		task.defer(function()
			if TreePosition.ClassName == "Part" then
				local found = false
				for _, v in ipairs(Trees:GetChildren()) do
					if v.ClassName == "Folder" and v.Name == TreePosition.Name and not found then
						found = v
					end
				end
				if not found then
					found = Instance.new("Folder")
					found.Name = TreePosition.Name
					found.Parent = Trees
				end
				TreePosition.Parent = found
				self:SpawnTree(TreePosition)
			end
		end)
	end)
end

function TreesController:GetTreeData()
	return require(script.Parent.TreeData)
end

function TreesController:SpawnTree(TreePosition: Part)
	local treeData = require(script.Parent.TreeData)[TreePosition.Name]
	local TreeAsset: Model = TreeAssets:FindFirstChild(TreePosition.Name)

	assert(treeData, "Tree data not found for " .. TreePosition.Name)
	assert(TreeAsset, "Tree asset not found for " .. TreePosition.Name)

	local Tree: Model = TreeAsset:Clone()
	local TreeFruitHolder: Folder = Tree:FindFirstChild("Fruits")
	local TreeSize: Vector3 = Tree:GetExtentsSize()
	Tree:PivotTo(
		TreePosition.CFrame
			* CFrame.new(0, TreeSize.Y / 2 - TreePosition.Size.Y / 2, 0)
			* CFrame.Angles(0, math.rad(math.random() * 360), 0)
	)

	Tree.Parent = TreePosition.Parent
	TreePosition:Destroy()

	for _, fruitPart in ipairs(TreeFruitHolder:GetChildren()) do
		for _ = 1, treeData.FruitsPerLog do
			self.FruitsController:SpawnFruit(Tree, fruitPart)
		end
	end
end

return TreesController
