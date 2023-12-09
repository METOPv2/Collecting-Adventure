-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

-- Fruits controller
local FruitsController = Knit.CreateController({
	Name = "FruitsController",
	FruitHarvested = Signal.new(),
	FruitsSold = Signal.new(),
	Initialized = Signal.new(),
	Initialazing = true,
})

function FruitsController:KnitInit()
	self.FruitsService = Knit.GetService("FruitsService")

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

	self.Initialazing = false
	self.Initialized:Fire()
end

function FruitsController:GetFruitLevel(fruit: string): number
	assert(fruit ~= nil, "Fruit is missing or nil.")
	if self.Initialazing then
		self.Initialized:Wait()
	end
	return self.FruitLevels[fruit]
end

function FruitsController:GetFruitLevels(): { [string]: number }
	if self.Initialazing then
		self.Initialized:Wait()
	end
	return self.FruitLevels
end

return FruitsController
