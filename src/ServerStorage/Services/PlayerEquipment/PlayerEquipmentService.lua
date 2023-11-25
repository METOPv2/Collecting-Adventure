-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)
local Signal = require(ReplicatedStorage.Packages.signal)

-- Data bases
local BagsDataBase = require(ServerStorage.Source.DataBases.Bags)

-- Player equipment service
local PlayerEquipmentService = Knit.CreateService({
	Name = "PlayerEquipmentService",
	Client = {
		BagEquipped = Knit.CreateSignal(),
	},
	BagEquipped = Signal.new(),
})

function PlayerEquipmentService:KnitInit()
	self.PlayerDataService = Knit.GetService("PlayerDataService")
end

function PlayerEquipmentService:GetEquippedBag(player: Player): string
	assert(player, "Player is missing or nil")
	return self.PlayerDataService:GetAsync(player, "EquippedBag")
end

function PlayerEquipmentService.Client:GetEquippedBag(player: Player): string
	return self.Server:GetEquippedBag(player)
end

function PlayerEquipmentService:EquipBag(player: Player, bag: string)
	assert(player, "Player is missing or nil.")
	assert(typeof(bag) == "string", `Bag must be string. Got {typeof(bag)}.`)
	if bag == "" or table.find(self.PlayerDataService:GetAsync(player, "Bags"), bag) then
		self.PlayerDataService:SetAsync(player, "EquippedBag", bag)
		self.Client.BagEquipped:Fire(player, bag)
	end
end

function PlayerEquipmentService.Client:EquipBag(player: Player, bag: string)
	self.Server:EquipBag(player, bag)
end

function PlayerEquipmentService:GetBagData(bag: string): BagsDataBase.DataBase
	assert(bag, "Bag is missing or nil.")
	return BagsDataBase[bag]
end

function PlayerEquipmentService.Client:GetBagData(_, bag: string): BagsDataBase.DataBase
	return self.Server:GetBagData(bag)
end

function PlayerEquipmentService:IsBagEquipped(player: Player, bag: string): boolean
	assert(player, "Player is missing or nil.")
	assert(bag, "Bag is missing or nil.")
	return self:GetEquippedBag(player) == bag
end

function PlayerEquipmentService.Client:IsBagEquipped(player: Player, bag: string): boolean
	return self.Server:IsBagEquipped(player, bag)
end

return PlayerEquipmentService