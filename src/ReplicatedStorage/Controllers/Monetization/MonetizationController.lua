-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Promise = require(ReplicatedStorage:WaitForChild("Packages").promise)

-- Player
local localPlayer = Players.LocalPlayer

-- Monetization controller
local MonetizationController = Knit.CreateController({
	Name = "MonetizationController",
	GamePasses = {
		671455721,
		175593072,
		175593268,
		175594858,
	},
	MyGamePasses = {},
})

function MonetizationController:KnitInit()
	self.MonetizationService = Knit.GetService("MonetizationService")

	for _, id in ipairs(self.GamePasses) do
		self:DoOwnGamepass(id)
			:andThen(function(owns)
				if owns then
					table.insert(self.MyGamePasses, id)
				end
			end)
			:catch(warn)
			:await()
	end
end

function MonetizationController:DoOwnGamepass(id: number)
	assert(id ~= nil, "Id is missing.")

	if table.find(self.MyGamePasses, id) then
		return Promise.new(function(resolve)
			resolve(true)
		end)
	end

	return Promise.new(function(resolve, reject)
		local success, result = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(localPlayer.UserId, id)
		end)

		if success then
			if result then
				table.insert(self.MyGamePasses, id)
			end
			resolve(result)
		else
			reject(result)
		end
	end)
end

function MonetizationController:BuyGamepass(id: number)
	assert(id ~= nil, "Id is missing.")
	return Promise.new(function(resolve, reject)
		local success, result = pcall(function()
			return MarketplaceService:PromptGamePassPurchase(localPlayer, id)
		end)

		if success then
			MarketplaceService.PromptGamePassPurchaseFinished:Connect(
				function(playerWhoWasPurchasing, gamepassId, wasPurchased)
					if playerWhoWasPurchasing == localPlayer and gamepassId == id then
						resolve(wasPurchased)
					end
				end
			)
		else
			reject(result)
		end
	end)
end

function MonetizationController:BuyProduct(id: number)
	assert(id ~= nil, "Id is missing.")
	return Promise.new(function(resolve, reject)
		local success, result = pcall(function()
			return MarketplaceService:PromptProductPurchase(localPlayer, id)
		end)

		if success then
			MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, wasPurchased)
				if userId == localPlayer.UserId and productId == id then
					resolve(wasPurchased)
				end
			end)
		else
			reject(result)
		end
	end)
end

return MonetizationController
