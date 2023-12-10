-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Promo code controller
local PromoCodeController = Knit.CreateController({
	Name = "PromoCodeController",
	Debounce = false,
})

function PromoCodeController:KnitInit()
	self.NotificationsController = Knit.GetController("NotificationsController")
	self.PromoCodeService = Knit.GetService("PromoCodeService")
	self.GuiController = Knit.GetController("GuiController")

	self.PromoCodeService
		:GetRedeemedPromoCodes()
		:andThen(function(promoCodes: {})
			self.RedeemedPromoCodes = promoCodes
		end)
		:catch(warn)
		:await()
	self.PromoCodeService.PromoCodeRedeemed:Connect(function(promoCode)
		table.insert(self.RedeemedPromoCodes, promoCode.PromoCode)
		self.GuiController:OpenGui("PromoCodeRewards", { promoCode = promoCode }, { CloseItSelf = true })
	end)
end

function PromoCodeController:Redeem(promoCode: string)
	assert(promoCode ~= nil, "Promo code is missing or nil.")
	if self.Debounce then
		return self.NotificationsController:new({
			text = `You can redeem another promo code in {math.round(
				(3 - (workspace:GetServerTimeNow() - self.Debounce)) * 10
			) / 10} seconds.`,
			title = "Cannot redeem promo code yet",
			duration = 15,
			type = "warn",
		})
	else
		self.Debounce = workspace:GetServerTimeNow()
		task.delay(3, function()
			self.Debounce = nil
		end)
	end
	if not self:DoesPromoCodeAlive(promoCode) then
		return self.NotificationsController:new({
			text = `Promo code "{promoCode}" expired or does not exist.`,
			title = "Cannot redeem this promo code",
			duration = 15,
			type = "warn",
		})
	end
	if self:DoesPromoCodeRedeemed(promoCode) then
		return self.NotificationsController:new({
			text = `Promo code "{promoCode}" has been already redeemed.`,
			title = "Cannot redeem this promo code",
			duration = 15,
			type = "warn",
		})
	end
	self.PromoCodeService:Redeem(promoCode):catch(warn)
end

function PromoCodeController:DoesPromoCodeAlive(promoCode: string): boolean
	assert(promoCode ~= nil, "Promo code is missing or nil.")
	if not self.DeadPromoCodes then
		self.DeadPromoCodes = {}
	end
	if table.find(self.DeadPromoCodes, promoCode) then
		return false
	end
	local alive
	self.PromoCodeService
		:DoesPromoCodeAlive(promoCode)
		:andThen(function(value)
			alive = value
			if value == false then
				table.insert(self.DeadPromoCodes, promoCode)
			end
		end)
		:catch(warn)
		:await()
	return alive
end

function PromoCodeController:DoesPromoCodeRedeemed(promoCode: string): boolean
	assert(promoCode ~= nil, "Promo code is missing or nil.")
	return table.find(self.RedeemedPromoCodes, promoCode) ~= nil
end

function PromoCodeController:GetRedeemedPromoCodes(): {}
	return self.RedeemedPromoCodes
end

return PromoCodeController
