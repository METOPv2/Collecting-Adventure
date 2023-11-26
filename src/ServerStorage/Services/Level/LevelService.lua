-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Level service
local LevelService = Knit.CreateService({
	Name = "LevelService",
	Client = {
		LevelUp = Knit.CreateSignal(),
		XpChanged = Knit.CreateSignal(),
	},
})

function LevelService:KnitInit()
	self.PlayerDataService = Knit.GetService("PlayerDataService")
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

function LevelService:LevelUp(player: Player)
	assert(player, "Player is missing or nil.")
	if self.PlayerDataService:GetAsync(player, "Xp") >= self:CalculateXpGoal(player) then
		self:IncrementXp(player, -self:CalculateXpGoal(player))
		self.PlayerDataService:IncrementAsync(player, "Level", 1)
		self.Client.LevelUp:Fire(player, self:GetLevel(player))
		self:LevelUp(player)
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
