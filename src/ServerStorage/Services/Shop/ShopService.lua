-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Data bases
local BagsDataBase = require(ServerStorage.Source.DataBases.Bags)
local GlovesDataBase = require(ServerStorage.Source.DataBases.Gloves)
local BootsDataBase = require(ServerStorage.Source.DataBases.Boots)

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
		return
	end
	if self.PlayerDataService:GetAsync(player, "FruitBucks") < BagsDataBase[bag].Price then
		return
	end
	self.PlayerDataService:IncrementAsync(player, "FruitBucks", -BagsDataBase[bag].Price)
	self.PlayerDataService:InsertInTableAsync(player, "Bags", bag)
end

function ShopService.Client:BuyBag(player: Player, bag: string)
	self.Server:BuyBag(player, bag)
end

function ShopService:BuyGloves(player: Player, gloves: string)
	assert(player, "Player is missing or nil.")
	assert(gloves, "Gloves is missing or nil.")
	assert(GlovesDataBase[gloves], `{gloves} gloves doesn't exist.`)
	if self.PlayerEquipmentService:HasGloves(player, gloves) then
		return
	end
	if self.PlayerDataService:GetAsync(player, "FruitBucks") < GlovesDataBase[gloves].Price then
		return
	end
	self.PlayerDataService:IncrementAsync(player, "FruitBucks", -GlovesDataBase[gloves].Price)
	self.PlayerDataService:InsertInTableAsync(player, "Gloves", gloves)
end

function ShopService.Client:BuyGloves(player: Player, gloves: string)
	self.Server:BuyGloves(player, gloves)
end

function ShopService:BuyBoots(player: Player, boots: string)
	assert(player, "Player is missing or nil.")
	assert(boots, "Boots is missing or nil.")
	assert(BootsDataBase[boots], `{boots} boots doesn't exist.`)
	if self.PlayerEquipmentService:HasBoots(player, boots) then
		return
	end
	if self.PlayerDataService:GetAsync(player, "FruitBucks") < BootsDataBase[boots].Price then
		return
	end
	self.PlayerDataService:IncrementAsync(player, "FruitBucks", -BootsDataBase[boots].Price)
	self.PlayerDataService:InsertInTableAsync(player, "Boots", boots)
end

function ShopService.Client:BuyBoots(player: Player, boots: string)
	self.Server:BuyBoots(player, boots)
end

return ShopService
