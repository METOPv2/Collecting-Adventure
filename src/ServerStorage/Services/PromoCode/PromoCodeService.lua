-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Promo code service
local PromoCodeService = Knit.CreateService({
	Name = "PromoCodeService",
	Client = {
		PromoCodeRedeemed = Knit.CreateSignal(),
	},
	PromoCodes = require(script.Parent.PromoCodes),
	Debounce = {},
})

function PromoCodeService:KnitInit()
	self.LevelService = Knit.GetService("LevelService")
	self.PlayerDataService = Knit.GetService("PlayerDataService")
	self.NotificationsService = Knit.GetService("NotificationsService")
end

function PromoCodeService:Redeem(player: Player, promoCode: string)
	assert(player ~= nil, "Player is missing or nil.")
	assert(promoCode ~= nil, "Promo code is missing or nil.")
	if self.Debounce[player] then
		return self.NotificationsService:new(player, {
			text = `You can redeem another promo code in {math.round(
				(3 - (workspace:GetServerTimeNow() - self.Debounce[player])) * 10
			) / 10} seconds.`,
			title = "Cannot redeem promo code yet",
			duration = 15,
			type = "warn",
		})
	else
		self.Debounce[player] = workspace:GetServerTimeNow()
		task.delay(3, function()
			self.Debounce[player] = nil
		end)
	end
	if not self:DoesPromoCodeAlive(promoCode) then
		return self.NotificationsService:new(player, {
			text = `Promo code "{promoCode}" expired or does not exist.`,
			title = "Cannot redeem this promo code",
			duration = 15,
			type = "warn",
		})
	end
	if self:DoesPromoCodeRedeemed(player, promoCode) then
		return self.NotificationsService:new(player, {
			text = `Promo code "{promoCode}" already redeemed.`,
			title = "Cannot redeem this promo code",
			duration = 15,
			type = "warn",
		})
	end
	for _, v in ipairs(self.PromoCodes) do
		if v.PromoCode == promoCode then
			for key, value in pairs(v.Rewards) do
				if key == "Xp" then
					self.LevelService:IncrementXp(player, value)
					continue
				end
				if typeof(self.PlayerDataService:GetAsync(player, key)) == "number" then
					self.PlayerDataService:IncrementAsync(player, key, value)
				end
			end
			self.Client.PromoCodeRedeemed:Fire(player, v)
			break
		end
	end
	self.PlayerDataService:InsertInTableAsync(player, "RedeemedPromoCodes", promoCode)
	self.NotificationsService:new(player, {
		text = `Promo code "{promoCode}" has been successfully redeemed.`,
		title = "Promo code redeemed",
		duration = 30,
		type = "info",
	})
end

function PromoCodeService.Client:Redeem(player: Player, promoCode: string)
	self.Server:Redeem(player, promoCode)
end

function PromoCodeService:DoesPromoCodeAlive(promoCode: string): boolean
	assert(promoCode ~= nil, "Promo code is missing or nil.")
	local alive = false
	for _, v in ipairs(self.PromoCodes) do
		if v.PromoCode == promoCode and not v.Expired then
			alive = true
			break
		end
	end
	return alive
end

function PromoCodeService.Client:DoesPromoCodeAlive(player: Player, promoCode: string): boolean
	return self.Server:DoesPromoCodeAlive(promoCode)
end

function PromoCodeService:DoesPromoCodeRedeemed(player: Player, promoCode: string): boolean
	assert(player ~= nil, "Player is missing or nil.")
	assert(promoCode ~= nil, "Promo code is missing or nil.")
	local redeemed = false
	for _, v in ipairs(self.PlayerDataService:GetAsync(player, "RedeemedPromoCodes")) do
		if v == promoCode then
			redeemed = true
			break
		end
	end
	return redeemed
end

function PromoCodeService.Client:DoesPromoCodeRedeemed(player: Player, promoCode: string): boolean
	return self.Server:DoesPromoCodeRedeemed(player, promoCode)
end

function PromoCodeService:GetRedeemedPromoCodes(player: Player): {}
	assert(player ~= nil, "Player is missing or nil.")
	return self.PlayerDataService:GetAsync(player, "RedeemedPromoCodes")
end

function PromoCodeService.Client:GetRedeemedPromoCodes(player: Player): {}
	return self.Server:GetRedeemedPromoCodes(player)
end

return PromoCodeService
