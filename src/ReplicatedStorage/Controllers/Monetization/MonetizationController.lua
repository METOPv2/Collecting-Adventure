-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Player
local localPlayer = Players.LocalPlayer

-- Monetization controller
local MonetizationController = Knit.CreateController({
	Name = "MonetizationController",
})

function MonetizationController:KnitInit()
	self.MonetizationService = Knit.GetService("MonetizationService")
end

function MonetizationController:DoOwnGamepass(id: number): boolean
	return self.MonetizationService:DoOwnGamepass(id)
end

function MonetizationController:BuyGamepass(id: number): (boolean, string?)
	return pcall(function()
		return MarketplaceService:PromptGamePassPurchase(localPlayer, id)
	end)
end

function MonetizationController:BuyProduct(id: number): (boolean, string?)
	return pcall(function()
		return MarketplaceService:PromptProductPurchase(localPlayer, id)
	end)
end

return MonetizationController
