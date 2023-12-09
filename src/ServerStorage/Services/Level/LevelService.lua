-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Data bases
local FruitsDataBase = require(ServerStorage.Source.DataBases.Fruits)

-- Level service
local LevelService = Knit.CreateService({
	Name = "LevelService",
	Client = {
		LevelUp = Knit.CreateSignal(),
		XpChanged = Knit.CreateSignal(),
	},
})

function LevelService:KnitInit()
	self.NotificationsService = Knit.GetService("NotificationsService")
	self.PlayerDataService = Knit.GetService("PlayerDataService")
	self.MarkerService = Knit.GetService("MarkerService")
	self.PlayerDataService.InitializedPlayer:Connect(function(player)
		self:LevelUp(player)
	end)
end

function LevelService:CalculateXpGoal(player: Player): number
	assert(player, "Player is missing or nil.")
	return self.PlayerDataService:GetAsync(player, "Level") * 5 + 5
end

function LevelService.Client:CalculateXpGoal(player: Player): number
	return self.Server:CalculateXpGoal(player)
end

function LevelService:IncrementXp(player: Player, amount: number)
	assert(player, "Player is missing or nil.")
	assert(amount, "Amount is missing or nil.")
	assert(typeof(amount) == "number", `Amount must be number. Got {typeof(amount)}.`)

	self.PlayerDataService:IncrementAsync(player, "Xp", amount)
	self.Client.XpChanged:Fire(player, self:GetXp(player))
	self:LevelUp(player)
end

function LevelService:LevelUp(player: Player, options: { levelUpped: number }?)
	assert(player, "Player is missing or nil.")
	if self.PlayerDataService:GetAsync(player, "Xp") >= self:CalculateXpGoal(player) then
		self:IncrementXp(player, -self:CalculateXpGoal(player))
		self.PlayerDataService:IncrementAsync(player, "Level", 1)
		self:LevelUp(player, { levelUpped = (options and options.levelUpped or 0) + 1 })
	else
		if options and options.levelUpped then
			self.Client.LevelUp:Fire(player, self:GetLevel(player), options.levelUpped)
		end
	end
end

function LevelService:GetLevel(player: Player): number
	assert(player, "Player is missing or nil.")
	return self.PlayerDataService:GetAsync(player, "Level")
end

function LevelService:GetXp(player: Player): number
	assert(player, "Player is missing or nil.")
	return self.PlayerDataService:GetAsync(player, "Xp")
end

function LevelService.Client:GetXp(player: Player): number
	return self.Server:GetXp(player)
end

function LevelService.Client:GetLevel(player: Player): number
	return self.Server:GetLevel(player)
end

return LevelService
