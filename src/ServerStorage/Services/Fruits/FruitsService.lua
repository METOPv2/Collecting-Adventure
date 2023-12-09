-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)
local Signal = require(ReplicatedStorage.Packages.signal)

-- Data bases
local BagsDataBase = require(ServerStorage.Source.DataBases.Bags)
local FruitsDataBase = require(ServerStorage.Source.DataBases.Fruits)

-- Types
type Fruit = {
	Name: string,
}

-- Fruit service
local FruitsService = Knit.CreateService({
	Name = "FruitsService",
	SellDebounce = {},
	Client = {
		FruitHarvested = Knit.CreateSignal(),
		FruitsSold = Knit.CreateSignal(),
	},
	FruitHarvested = Signal.new(),
	FruitsSold = Signal.new(),
})

function FruitsService:KnitInit()
	self.PlayerDataService = Knit.GetService("PlayerDataService")
	self.LevelService = Knit.GetService("LevelService")
	self.NotificationsService = Knit.GetService("NotificationsService")
	self.SFXService = Knit.GetService("SFXService")
	self.GuiService = Knit.GetService("GuiService")
	self.MarkerService = Knit.GetService("MarkerService")
	self.NotificationsService = Knit.GetService("NotificationsService")
end

function FruitsService:KnitStart()
	for _, sellPart: Part in ipairs(workspace.SellParts:GetChildren()) do
		sellPart.Touched:Connect(function(otherPart)
			local character = otherPart.Parent
			local player = Players:GetPlayerFromCharacter(character)
			if not player then
				return
			end
			self:SellFruits(player)
		end)
	end
end

function FruitsService:AddFruit(player: Player, fruit: string)
	assert(player ~= nil, "Player is missing or nil.")
	assert(fruit ~= nil, "Fruit is missing or nil.")

	local playerFruits = self.PlayerDataService:GetAsync(player, "Fruits")
	local playerBag = self.PlayerDataService:GetAsync(player, "EquippedBag")
	local bagData = BagsDataBase[playerBag]
	local fruitData = FruitsDataBase[fruit]

	if playerBag == "" then
		self.GuiService:OpenGui(
			player,
			"Inventory",
			{ starterPage = "Bags" },
			{ CloseItSelf = true, DontCloseIfAlreadyOpen = true }
		)

		return self.NotificationsService:new(player, {
			text = "You are unable to harvest fruits without an equipped bag. Consider equipping it from your inventory.",
			title = "No bag is equipped",
			duration = 15,
			type = "warn",
		})
	end

	if playerBag == "" or #playerFruits + 1 > bagData.MaxFruits then
		self.MarkerService:New(player, workspace.SellParts, { Key = "Sell" })

		return self.NotificationsService:new(player, {
			text = "Sell your current fruits to have more capacity in your bag.",
			title = "Max fruits reached",
			duration = 15,
			type = "warn",
		})
	end

	if self.LevelService:GetLevel(player) < fruitData.Level then
		return self.NotificationsService:new(player, {
			text = `Your current level is {self.LevelService:GetLevel(player)}, and you can't harvest fruit which requires {fruitData.Level - self.LevelService:GetLevel(
				player
			)} more levels.`,
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

	self.LevelService:IncrementXp(player, fruitData.Xp)
	self.PlayerDataService:InsertInTableAsync(player, "Fruits", newFruit)

	-- Play SFX
	self.SFXService:PlayLocalSFX(player, "Pop")

	-- Check if bag is already full
	if playerBag == "" or #self.PlayerDataService:GetAsync(player, "Fruits") >= bagData.MaxFruits then
		self.MarkerService:New(player, workspace.SellParts, { Key = "Sell" })

		return self.NotificationsService:new(player, {
			text = "Sell your current fruits to have more capacity in your bag.",
			title = "Max fruits reached",
			duration = 15,
			type = "warn",
		})
	end

	self.Client.FruitHarvested:Fire(player, fruit)
	self.FruitHarvested:Fire(player, fruit)
end

function FruitsService:SellFruits(player: Player)
	local playerId = tostring(player.UserId)
	if self.SellDebounce[playerId] then
		return
	end
	self.SellDebounce[playerId] = true

	local SFXService = Knit.GetService("SFXService")
	local NotificationsService = Knit.GetService("NotificationsService")
	local PlayerDataService = Knit.GetService("PlayerDataService")
	local Fruits = PlayerDataService:GetAsync(player, "Fruits")

	if #Fruits ~= 0 then
		local fruitBucks, fruits = 0, 0
		for _, fruit in pairs(Fruits) do
			local fruitData = FruitsDataBase[fruit.Id]
			PlayerDataService:RemoveAsync(player, "Fruits", fruit)
			PlayerDataService:IncrementAsync(player, "FruitBucks", fruitData.SellValue)
			fruitBucks += fruitData.SellValue
			fruits += 1
		end
		NotificationsService:new(player, {
			text = `You earned {fruitBucks} fruit bucks for selling {fruits} fruits.`,
			title = "Fruits sold",
			duration = 10,
			type = "sell",
		})
		SFXService:PlayLocalSFX(player, "CashRegister")
	end

	self.SellDebounce[playerId] = nil
	self.FruitsSold:Fire(player)
	self.Client.FruitsSold:Fire(player)
end

function FruitsService:GetFruitLevels(): { [string]: number }
	local levels = {}

	for name, data in pairs(FruitsDataBase) do
		levels[name] = data.Level
	end

	return levels
end

function FruitsService.Client:GetFruitLevels(): { [string]: number }
	return self.Server:GetFruitLevels()
end

return FruitsService