-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)
local Signal = require(ReplicatedStorage.Packages.signal)

-- Data bases
local BagsDataBase = require(ServerStorage.Source.DataBases.Bags)
local GlovesDataBase = require(ServerStorage.Source.DataBases.Gloves)
local BootsDataBase = require(ServerStorage.Source.DataBases.Boots)

-- Player equipment service
local PlayerEquipmentService = Knit.CreateService({
	Name = "PlayerEquipmentService",
	Client = {
		BagEquipped = Knit.CreateSignal(),
		BagAdded = Knit.CreateSignal(),
		GlovesEquipped = Knit.CreateSignal(),
		GlovesAdded = Knit.CreateSignal(),
		BootsEquipped = Knit.CreateSignal(),
		BootsAdded = Knit.CreateSignal(),
	},
	BagEquipped = Signal.new(),
	GlovesEquipped = Signal.new(),
	BootsEquipped = Signal.new(),
})

function PlayerEquipmentService:KnitInit()
	self.PlayerDataService = Knit.GetService("PlayerDataService")

	self.PlayerDataService.DataChanged:Connect(function(player, key, value)
		if key == "Bags" then
			self.Client.BagAdded:Fire(player, value)
		elseif key == "Gloves" then
			self.Client.GlovesAdded:Fire(player, value)
		elseif key == "Boots" then
			self.Client.BootsAdded:Fire(player, value)
		elseif key == "EquippedGloves" then
			self.GlovesEquipped:Fire(player, value)
			self.Client.GlovesEquipped:Fire(player, value)
		elseif key == "EquippedBag" then
			self.BagEquipped:Fire(player, value)
			self.Client.BagEquipped:Fire(player, value)
		elseif key == "EquippedBoots" then
			self.BootsEquipped:Fire(player, value)
			self.Client.BootsEquipped:Fire(player, value)
		end
	end)
end

function PlayerEquipmentService:GetEquippedBag(player: Player): string
	assert(player, "Player is missing or nil")
	return self.PlayerDataService:GetAsync(player, "EquippedBag")
end

function PlayerEquipmentService.Client:GetEquippedBag(player: Player): string
	return self.Server:GetEquippedBag(player)
end

function PlayerEquipmentService:GetEquippedBoots(player: Player): string
	assert(player, "Player is missing or nil")
	return self.PlayerDataService:GetAsync(player, "EquippedBoots")
end

function PlayerEquipmentService.Client:GetEquippedBoots(player: Player): string
	return self.Server:GetEquippedBoots(player)
end

function PlayerEquipmentService:GetEquippedGloves(player: Player): string
	assert(player, "Player is missing or nil")
	return self.PlayerDataService:GetAsync(player, "EquippedGloves")
end

function PlayerEquipmentService.Client:GetEquippedGloves(player: Player): string
	return self.Server:GetEquippedGloves(player)
end

function PlayerEquipmentService:EquipBag(player: Player, bag: string)
	assert(player, "Player is missing or nil.")
	assert(typeof(bag) == "string", `Bag must be string. Got {typeof(bag)}.`)
	if bag == "" or table.find(self.PlayerDataService:GetAsync(player, "Bags"), bag) then
		self.PlayerDataService:SetAsync(player, "EquippedBag", bag)
	end
end

function PlayerEquipmentService.Client:EquipBag(player: Player, bag: string)
	self.Server:EquipBag(player, bag)
end

function PlayerEquipmentService:EquipBoots(player: Player, boots: string)
	assert(player, "Player is missing or nil.")
	assert(typeof(boots) == "string", `Boots must be string. Got {typeof(boots)}.`)
	if boots == "" or table.find(self.PlayerDataService:GetAsync(player, "Boots"), boots) then
		self.PlayerDataService:SetAsync(player, "EquippedBoots", boots)
	end
end

function PlayerEquipmentService.Client:EquipBoots(player: Player, boots: string)
	self.Server:EquipBoots(player, boots)
end

function PlayerEquipmentService:EquipGloves(player: Player, gloves: string)
	assert(player, "Player is missing or nil.")
	assert(typeof(gloves) == "string", `Gloves must be string. Got {typeof(gloves)}.`)
	if gloves == "" or table.find(self.PlayerDataService:GetAsync(player, "Gloves"), gloves) then
		self.PlayerDataService:SetAsync(player, "EquippedGloves", gloves)
	end
end

function PlayerEquipmentService.Client:EquipGloves(player: Player, gloves: string)
	self.Server:EquipGloves(player, gloves)
end

function PlayerEquipmentService:GetBagData(bag: string?): BagsDataBase.DataBase
	if bag then
		return BagsDataBase[bag]
	else
		return BagsDataBase
	end
end

function PlayerEquipmentService.Client:GetBagData(_, bag: string?): BagsDataBase.DataBase
	return self.Server:GetBagData(bag)
end

function PlayerEquipmentService:GetBootsData(boots: string?): BootsDataBase.DataBase
	if boots then
		return BootsDataBase[boots]
	else
		return BootsDataBase
	end
end

function PlayerEquipmentService.Client:GetBootsData(_, boots: string?): BootsDataBase.DataBase
	return self.Server:GetBootsData(boots)
end

function PlayerEquipmentService:GetGlovesData(gloves: string?): GlovesDataBase.DataBase
	if gloves then
		return GlovesDataBase[gloves]
	else
		return GlovesDataBase
	end
end

function PlayerEquipmentService.Client:GetGlovesData(_, gloves: string?): GlovesDataBase.DataBase
	return self.Server:GetGlovesData(gloves)
end

function PlayerEquipmentService:IsBagEquipped(player: Player, bag: string): boolean
	assert(player, "Player is missing or nil.")
	assert(bag, "Bag is missing or nil.")
	return self:GetEquippedBag(player) == bag
end

function PlayerEquipmentService.Client:IsBagEquipped(player: Player, bag: string): boolean
	return self.Server:IsBagEquipped(player, bag)
end

function PlayerEquipmentService:IsGlovesEquipped(player: Player, gloves: string): boolean
	assert(player, "Player is missing or nil.")
	assert(gloves, "Gloves is missing or nil.")
	return self:GetEquippedGloves(player) == gloves
end

function PlayerEquipmentService.Client:IsGlovesEquipped(player: Player, gloves: string): boolean
	return self.Server:IsGlovesEquipped(player, gloves)
end

function PlayerEquipmentService:IsBootsEquipped(player: Player, boots: string): boolean
	assert(player, "Player is missing or nil.")
	assert(boots, "Boots is missing or nil.")
	return self:GetEquippedBoots(player) == boots
end

function PlayerEquipmentService.Client:IsBootsEquipped(player: Player, boots: string): boolean
	return self.Server:IsBootsEquipped(player, boots)
end

function PlayerEquipmentService:DoOwnBag(player: Player, bag: string): boolean
	assert(player, "Player is missing or nil.")
	assert(bag, "Bag is missing or nil.")
	return table.find(self.PlayerDataService:GetAsync(player, "Bags"), bag) ~= nil
end

function PlayerEquipmentService.Client:DoOwnBag(player: Player, bag: string): boolean
	return self.Server:DoOwnBag(player, bag)
end

function PlayerEquipmentService:HasGloves(player: Player, gloves: string): boolean
	assert(player, "Player is missing or nil.")
	assert(gloves, "Gloves is missing or nil.")
	return table.find(self.PlayerDataService:GetAsync(player, "Gloves"), gloves) ~= nil
end

function PlayerEquipmentService.Client:HasGloves(player: Player, gloves: string): boolean
	return self.Server:HasGloves(player, gloves)
end

function PlayerEquipmentService:HasBoots(player: Player, boots: string): boolean
	assert(player, "Player is missing or nil.")
	assert(boots, "Boots is missing or nil.")
	return table.find(self.PlayerDataService:GetAsync(player, "Boots"), boots) ~= nil
end

function PlayerEquipmentService.Client:HasBoots(player: Player, Boots: string): boolean
	return self.Server:HasBoots(player, Boots)
end

function PlayerEquipmentService:GetBags(player: Player): {}
	assert(player, "Player is missing or nil.")
	return self.PlayerDataService:GetAsync(player, "Bags")
end

function PlayerEquipmentService.Client:GetBags(player: Player): {}
	return self.Server:GetBags(player)
end

function PlayerEquipmentService:GetGloves(player: Player): {}
	assert(player, "Player is missing or nil.")
	return self.PlayerDataService:GetAsync(player, "Gloves")
end

function PlayerEquipmentService.Client:GetGloves(player: Player): {}
	return self.Server:GetGloves(player)
end

function PlayerEquipmentService:GetBoots(player: Player): {}
	assert(player, "Player is missing or nil.")
	return self.PlayerDataService:GetAsync(player, "Boots")
end

function PlayerEquipmentService.Client:GetBoots(player: Player): {}
	return self.Server:GetBoots(player)
end

return PlayerEquipmentService
