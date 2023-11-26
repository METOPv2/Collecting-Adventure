-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Data bases
local BagsDataBase = require(ServerStorage.Source.DataBases.Bags)

-- Shop service
local ShopService = Knit.CreateService({
	Name = "ShopService",
	Client = {},
})

function ShopService:KnitInit()
	self.PlayerDataService = Knit.GetService("PlayerDataService")
	self.PlayerEquipmentService = Knit.GetService("PlayerEquipmentService")
end

function ShopService:BuyBag(player: Player, bag: string)
	assert(player, "Player is missing or nil.")
	assert(bag, "Bag is missing or nil.")
	assert(BagsDataBase[bag], `{bag} bag doesn't exist.`)
	if self.PlayerEquipmentService:DoOwnBag(player, bag) then
		return warn("Aready own this bag.")
	end
	if self.PlayerDataService:GetAsync(player, "FruitBucks") < BagsDataBase[bag].Price then
		return warn("Not enough fruit bucks.")
	end
	self.PlayerDataService:IncrementAsync(player, "FruitBucks", -BagsDataBase[bag].Price)
	self.PlayerDataService:InsertInTableAsync(player, "Bags", bag)
end

function ShopService.Client:BuyBag(player: Player, bag: string)
	self.Server:BuyBag(player, bag)
end

return ShopService
