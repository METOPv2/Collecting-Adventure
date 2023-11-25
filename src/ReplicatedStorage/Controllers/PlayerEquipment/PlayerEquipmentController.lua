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
})

function PlayerEquipmentController:KnitInit()
	self.PlayerEquipmentService = Knit.GetService("PlayerEquipmentService")

	self.PlayerEquipmentService
		:GetEquippedBag()
		:andThen(function(equippedBag: string)
			self.EquippedBag = equippedBag
			self.BagEquipped:Fire(equippedBag)
		end)
		:catch(warn)
		:await()

	self.PlayerEquipmentService.BagEquipped:Connect(function(equippedBag: string)
		self.EquippedBag = equippedBag
		self.BagEquipped:Fire(equippedBag)
	end)
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

function PlayerEquipmentController:GetBagData(bag: string): {}
	assert(bag, "Bag is missing or nil.")
	if not self.BagData[bag] then
		self.PlayerEquipmentService
			:GetBagData(bag)
			:andThen(function(value)
				self.BagData[bag] = value
			end)
			:catch(warn)
			:await()
	end
	return self.BagData[bag]
end

return PlayerEquipmentController
