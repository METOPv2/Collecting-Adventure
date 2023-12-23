-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

-- Player equipment controller
local PlayerEquipmentController = Knit.CreateController({
	Name = "PlayerEquipmentController",
	EquippedBag = "",
	EquippedGloves = "",
	EquippedBoots = "",
	BagEquipped = Signal.new(),
	GlovesEquipped = Signal.new(),
	BootsEquipped = Signal.new(),
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

	self.PlayerEquipmentService
		:GetGloves()
		:andThen(function(gloves)
			self.Gloves = gloves
		end)
		:catch(warn)
		:await()

	self.PlayerEquipmentService
		:GetGlovesData()
		:andThen(function(glovesData)
			self.GlovesData = glovesData
		end)
		:catch(warn)
		:await()

	self.PlayerEquipmentService
		:GetEquippedGloves()
		:andThen(function(equippedGloves: string)
			self.EquippedGloves = equippedGloves
			self.GlovesEquipped:Fire(equippedGloves)
		end)
		:catch(warn)
		:await()

	self.PlayerEquipmentService
		:GetBoots()
		:andThen(function(boots)
			self.Boots = boots
		end)
		:catch(warn)
		:await()

	self.PlayerEquipmentService
		:GetBootsData()
		:andThen(function(bootsData)
			self.BootsData = bootsData
		end)
		:catch(warn)
		:await()

	self.PlayerEquipmentService
		:GetEquippedBoots()
		:andThen(function(equippedBoots: string)
			self.EquippedBoots = equippedBoots
			self.BootsEquipped:Fire(equippedBoots)
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

	self.PlayerEquipmentService.GlovesAdded:Connect(function(gloves)
		self.Gloves = gloves
	end)

	self.PlayerEquipmentService.GlovesEquipped:Connect(function(equippedGloves: string)
		self.EquippedGloves = equippedGloves
		self.GlovesEquipped:Fire(equippedGloves)
		if equippedGloves ~= "" then
			self.SFXController:PlaySFX("Equip")
		else
			self.SFXController:PlaySFX("Unequip")
		end
	end)

	self.PlayerEquipmentService.BootsAdded:Connect(function(boots)
		self.Boots = boots
	end)

	self.PlayerEquipmentService.BootsEquipped:Connect(function(equippedBoots: string)
		self.EquippedBoots = equippedBoots
		self.BootsEquipped:Fire(equippedBoots)
		if equippedBoots ~= "" then
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

function PlayerEquipmentController:GetEquippedGloves(): string
	if self.EquippedGloves == nil then
		self.GlovesEquipped:Wait()
	end

	return self.EquippedGloves
end

function PlayerEquipmentController:GetEquippedBoots(): string
	if self.EquippedBoots == nil then
		self.EquippedBoots:Wait()
	end

	return self.EquippedBoots
end

function PlayerEquipmentController:EquipBag(bag: string)
	assert(bag, "Bag is missing or nil.")
	self.PlayerEquipmentService:EquipBag(bag)
end

function PlayerEquipmentController:EquipGloves(gloves: string)
	assert(gloves, "Gloves is missing or nil.")
	self.PlayerEquipmentService:EquipGloves(gloves)
end

function PlayerEquipmentController:EquipBoots(boots: string)
	assert(boots, "Boots is missing or nil.")
	self.PlayerEquipmentService:EquipBoots(boots)
end

function PlayerEquipmentController:IsBagEquipped(bag: string): boolean
	assert(bag, "Bag is missing or nil.")
	if self.EquippedBag == nil then
		self.BagEquipped:Wait()
	end
	return self.EquippedBag == bag
end

function PlayerEquipmentController:IsGlovesEquipped(gloves: string): boolean
	assert(gloves, "Gloves is missing or nil.")
	if self.EquippedGloves == nil then
		self.GlovesEquipped:Wait()
	end
	return self.EquippedGloves == gloves
end

function PlayerEquipmentController:IsBootsEquipped(boots: string): boolean
	assert(boots, "Boots is missing or nil.")
	if self.EquippedBoots == nil then
		self.BootsEquipped:Wait()
	end
	return self.EquippedBoots == boots
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

function PlayerEquipmentController:GetGlovesData(gloves: string?): {}
	if self.Initializing then
		self.Initialized:Wait()
	end

	if gloves then
		return self.GlovesData[gloves]
	else
		return self.GlovesData
	end
end

function PlayerEquipmentController:GetBootsData(boots: string?): {}
	if self.Initializing then
		self.Initialized:Wait()
	end

	if boots then
		return self.BootsData[boots]
	else
		return self.BootsData
	end
end

function PlayerEquipmentController:DoOwnBag(bag: string): boolean
	if self.Initializing then
		self.Initialized:Wait()
	end

	return table.find(self.Bags, bag) ~= nil
end

function PlayerEquipmentController:HasGloves(gloves: string): boolean
	if self.Initializing then
		self.Initialized:Wait()
	end

	return table.find(self.Gloves, gloves) ~= nil
end

function PlayerEquipmentController:HasBoots(boots: string): boolean
	if self.Initializing then
		self.Initialized:Wait()
	end

	return table.find(self.Boots, boots) ~= nil
end

function PlayerEquipmentController:GetBags()
	if self.Initializing then
		self.Initialized:Wait()
	end

	return self.Bags
end

function PlayerEquipmentController:GetGloves()
	if self.Initializing then
		self.Initialized:Wait()
	end

	return self.Gloves
end

function PlayerEquipmentController:GetBoots()
	if self.Initializing then
		self.Initialized:Wait()
	end

	return self.Boots
end

return PlayerEquipmentController
