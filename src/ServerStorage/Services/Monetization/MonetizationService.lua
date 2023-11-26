-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Monetization service
local MonetizationService = Knit.CreateService({
	Name = "MonetizationService",
})

function MonetizationService:KnitInit()
	self.PlayerDataService = Knit.GetService("PlayerDataService")

	self.Functions = {
		[1694976189] = function(reciept)
			local player = Players:GetPlayerByUserId(reciept.PlayerId)
			if player == nil then
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
			self.PlayerDataService:IncrementAsync(player, "FruitBucks", 5)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end,
		[1694976191] = function(reciept)
			local player = Players:GetPlayerByUserId(reciept.PlayerId)
			if player == nil then
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
			self.PlayerDataService:IncrementAsync(player, "FruitBucks", 25)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end,
		[1694976188] = function(reciept)
			local player = Players:GetPlayerByUserId(reciept.PlayerId)
			if player == nil then
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
			self.PlayerDataService:IncrementAsync(player, "FruitBucks", 50)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end,
		[1694976190] = function(reciept)
			local player = Players:GetPlayerByUserId(reciept.PlayerId)
			if player == nil then
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
			self.PlayerDataService:IncrementAsync(player, "FruitBucks", 100)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end,
	}

	MarketplaceService.ProcessReceipt = function(reciept)
		return self.Functions[reciept.ProductId](reciept)
	end
end

function MonetizationService:DoOwnGamepass(player: Player, id: number): boolean
	assert(player, "Player is missing or nil.")
	assert(id, "Id is missing or nil.")
	return MarketplaceService:UserOwnsGamePassAsync(player, id)
end

function MonetizationService.Client:DoOwnGamepass(player: Player, id: number): boolean
	return self.Server:DoOwnGamepass(player, id)
end

function MonetizationService:BuyGamepass(player: Player, id: number): (boolean, string?)
	assert(player, "Player is missing or nil.")
	assert(id, "Id is missing or nil.")

	return pcall(function()
		return MarketplaceService:PromptGamePassPurchase(player, id)
	end)
end

function MonetizationService:BuyProduct(player: Player, id: number): (boolean, string?)
	assert(player, "Player is missing or nil.")
	assert(id, "Id is missing or nil.")

	return pcall(function()
		return MarketplaceService:PromptProductPurchase(player, id)
	end)
end

return MonetizationService
