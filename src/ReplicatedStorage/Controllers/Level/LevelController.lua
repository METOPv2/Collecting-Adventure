local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

local LevelController = Knit.CreateController({
	Name = "LevelController",
	Initializing = true,
	Initialized = Signal.new(),
	LevelUp = Signal.new(),
	XpChanged = Signal.new(),
})

function LevelController:KnitInit()
	self.LevelService = Knit.GetService("LevelService")

	self.LevelService
		:GetXp()
		:andThen(function(xp)
			self.Xp = xp
		end)
		:catch(warn)
		:await()

	self.LevelService
		:GetLevel()
		:andThen(function(level)
			self.Level = level
		end)
		:catch(warn)
		:await()

	self.LevelService.LevelUp:Connect(function(level)
		self.Level = level
		self.LevelUp:Fire(level)
	end)

	self.LevelService.XpChanged:Connect(function(xp)
		self.Xp = xp
		self.XpChanged:Fire(xp)
	end)

	self.Initialized:Fire()
	self.Initializing = false
end

function LevelController:CalculateXpGoal(): number
	local xpGoal = nil

	self.LevelService
		:CalculateXpGoal()
		:andThen(function(xp)
			xpGoal = xp
		end)
		:catch(warn)
		:await()

	return xpGoal
end

function LevelController:GetXp()
	if self.Initializing then
		self.Initialized:Wait()
	end

	return self.Xp
end

function LevelController:GetLevel()
	if self.Initializing then
		self.Initialized:Wait()
	end

	return self.Level
end

return LevelController
