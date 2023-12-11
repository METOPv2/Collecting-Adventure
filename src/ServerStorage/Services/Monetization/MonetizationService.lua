-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)
local Promise = require(ReplicatedStorage.Packages.promise)

-- Monetization service
local MonetizationService = Knit.CreateService({
	Name = "MonetizationService",
	PlayersGamePasses = {},
	GamePasses = {
		671455721,
		175593072,
		175593268,
		175594858,
	},
})

function MonetizationService:KnitInit()
	self.SFXService = Knit.GetService("SFXService")
	self.PlayerDataService = Knit.GetService("PlayerDataService")

	Players.PlayerAdded:Connect(function(player)
		self.PlayersGamePasses[player.UserId] = {}
		for _, id in ipairs(self.GamePasses) do
			self:DoOwnGamepass(player, id)
				:andThen(function(owns)
					if owns then
						table.insert(self.PlayersGamePasses[player.UserId], id)
					end
				end)
				:catch(warn)
				:await()
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		if self.PlayerDataService[player.UserId] then
			self.PlayerDataService[player.UserId] = nil
		end
	end)

	self.Functions = {
		[1694976189] = function(reciept)
			local player = Players:GetPlayerByUserId(reciept.PlayerId)
			if player == nil then
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
			self.PlayerDataService:IncrementAsync(player, "FruitBucks", 5)
			self.SFXService:PlayLocalSFX(player, "CashRegister")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end,
		[1694976191] = function(reciept)
			local player = Players:GetPlayerByUserId(reciept.PlayerId)
			if player == nil then
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
			self.PlayerDataService:IncrementAsync(player, "FruitBucks", 25)
			self.SFXService:PlayLocalSFX(player, "CashRegister")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end,
		[1694976188] = function(reciept)
			local player = Players:GetPlayerByUserId(reciept.PlayerId)
			if player == nil then
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
			self.PlayerDataService:IncrementAsync(player, "FruitBucks", 50)
			self.SFXService:PlayLocalSFX(player, "CashRegister")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end,
		[1694976190] = function(reciept)
			local player = Players:GetPlayerByUserId(reciept.PlayerId)
			if player == nil then
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
			self.PlayerDataService:IncrementAsync(player, "FruitBucks", 100)
			self.SFXService:PlayLocalSFX(player, "CashRegister")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end,
	}

	MarketplaceService.ProcessReceipt = function(reciept)
		return self.Functions[reciept.ProductId](reciept)
	end
end

function MonetizationService:DoOwnGamepass(player: Player, id: number)
	assert(player ~= nil, "Player is missing.")
	assert(id ~= nil, "Id is missing.")
	if self.PlayersGamePasses[player.UserId] then
		if table.find(self.PlayersGamePasses[player.UserId], id) then
			return Promise.new(function(resolve)
				resolve(true)
			end)
		end
	end
	return Promise.new(function(resolve, reject)
		local success, result = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, id)
		end)

		if success then
			if result then
				table.insert(self.PlayersGamePasses[player.UserId], id)
			end
			resolve(result)
		else
			reject(result)
		end
	end)
end

function MonetizationService:BuyGamepass(player: Player, id: number)
	assert(player ~= nil, "Player is missing.")
	assert(id ~= nil, "Id is missing.")
	return Promise.new(function(resolve, reject)
		local success, result = pcall(function()
			return MarketplaceService:PromptGamePassPurchase(player, id)
		end)

		if success then
			MarketplaceService.PromptGamePassPurchaseFinished:Connect(
				function(playerWhoWasPurchasing, gamepassId, wasPurchased)
					if playerWhoWasPurchasing == player and gamepassId == id then
						resolve(wasPurchased)
					end
				end
			)
		else
			reject(result)
		end
	end)
end

function MonetizationService:BuyProduct(player: Player, id: number): (boolean, string?)
	assert(player ~= nil, "Player is missing.")
	assert(id ~= nil, "Id is missing.")
	return Promise.new(function(resolve, reject)
		local success, errorMessag = pcall(function()
			return MarketplaceService:PromptProductPurchase(player, id)
		end)

		if success then
			MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, wasPurchased)
				if userId == player.UserId and productId == id then
					resolve(wasPurchased)
				end
			end)
		else
			reject(errorMessag)
		end
	end)
end

return MonetizationService
