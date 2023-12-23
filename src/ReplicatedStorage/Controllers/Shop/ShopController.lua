local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

local ShopController = Knit.CreateController({
	Name = "ShopController",
})

function ShopController:KnitInit()
	self.ShopService = Knit.GetService("ShopService")
end

function ShopController:BuyBag(bag: string)
	assert(bag, "Bag is missing or nil.")
	self.ShopService:BuyBag(bag)
end

function ShopController:BuyGloves(gloves: string)
	assert(gloves, "Gloves is missing or nil.")
	self.ShopService:BuyGloves(gloves)
end

return ShopController
