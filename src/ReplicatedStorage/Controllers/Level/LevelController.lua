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
	self.NotificationsController = Knit.GetController("NotificationsController")
	self.FruitsController = Knit.GetController("FruitsController")
	self.MarkerController = Knit.GetController("MarkerController")

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

	self.LevelService.LevelUp:Connect(function(newLevel: number, levelUpped: number)
		self.Level = newLevel
		self.LevelUp:Fire(newLevel)

		self.NotificationsController:new({
			text = `You level upped from level {newLevel - levelUpped} to {newLevel}. Congrats! :)`,
			title = "Level Up",
			duration = 15,
			type = "levelUp",
		})

		for name, level in pairs(self.FruitsController:GetFruitLevels()) do
			if level > (newLevel - levelUpped) and newLevel >= level then
				self.NotificationsController:new({
					text = `Now you're able to harvest "{name}" fruit.`,
					title = "Unlocked new fruit to harvest",
					duration = 15,
					type = "info",
				})
				self.MarkerController:New(
					workspace:WaitForChild("Spawnpoints"):WaitForChild(name).Position,
					{ Key = `{name}_Unlocked`, Duration = -1 }
				)
			end
		end
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
