-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

-- Player equipment controller
local PlayerEquipmentController = Knit.CreateController({
	Name = "PlayerEquipmentController",
	EquippedBag = "",
	BagEquipped = Signal.new(),
	Initialized = Signal.new(),
	Initializing = true,
})

function PlayerEquipmentController:KnitInit()
	self.PlayerEquipmentService = Knit.GetService("PlayerEquipmentService")
	self.SFXController = Knit.GetController("SFXController")

	self.PlayerEquipmentService
		:GetBags()
		:andThen(function(bags)
			self.Bags = bags
		end)
		:catch(warn)
		:await()

	self.PlayerEquipmentService
		:GetBagData()
		:andThen(function(bagData)
			self.BagData = bagData
		end)
		:catch(warn)
		:await()

	self.PlayerEquipmentService
		:GetEquippedBag()
		:andThen(function(equippedBag: string)
			self.EquippedBag = equippedBag
			self.BagEquipped:Fire(equippedBag)
		end)
		:catch(warn)
		:await()

	self.PlayerEquipmentService.BagAdded:Connect(function(bags)
		self.Bags = bags
	end)

	self.PlayerEquipmentService.BagEquipped:Connect(function(equippedBag: string)
		self.EquippedBag = equippedBag
		self.BagEquipped:Fire(equippedBag)
		if equippedBag ~= "" then
			self.SFXController:PlaySFX("Equip")
		else
			self.SFXController:PlaySFX("Unequip")
		end
	end)

	self.Initializing = false
	self.Initialized:Fire()
end

function PlayerEquipmentController:GetEquippedBag(): string
	if self.EquippedBag == nil then
		self.BagEquipped:Wait()
	end

	return self.EquippedBag
end

function PlayerEquipmentController:EquipBag(bag: string)
	assert(bag, "Bag is missing or nil.")
	self.PlayerEquipmentService:EquipBag(bag)
end

function PlayerEquipmentController:IsBagEquipped(bag: string): boolean
	assert(bag, "Bag is missing or nil.")
	if self.EquippedBag == nil then
		self.BagEquipped:Wait()
	end
	return self.EquippedBag == bag
end

function PlayerEquipmentController:GetBagData(bag: string?): {}
	if self.Initializing then
		self.Initialized:Wait()
	end

	if bag then
		return self.BagData[bag]
	else
		return self.BagData
	end
end

function PlayerEquipmentController:DoOwnBag(bag: string): boolean
	if self.Initializing then
		self.Initialized:Wait()
	end

	return table.find(self.Bags, bag) ~= nil
end

function PlayerEquipmentController:GetBags()
	if self.Initializing then
		self.Initialized:Wait()
	end

	return self.Bags
end

return PlayerEquipmentController
