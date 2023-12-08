-- Services
local RobloxBadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)
local Signal = require(ReplicatedStorage.Packages.signal)

-- Knit badge service
local KnitBadgeService = Knit.CreateService({
	Name = "BadgeService",
	BadgeAwarded = Signal.new(),
	BadgeIds = {
		AlphaPlayer = 2145539523,
	},
	BadgeNames = {
		AlphaPlayer = "Alpha Player",
	},
})

function KnitBadgeService:KnitInit()
	self.NotificationsService = Knit.GetService("NotificationsService")
end

function KnitBadgeService:KnitStart()
	for _, player in ipairs(Players:GetPlayers()) do
		coroutine.wrap(function()
			self:AwardBadge(player, "AlphaPlayer")
		end)()
	end

	Players.PlayerAdded:Connect(function(player)
		self:AwardBadge(player, "AlphaPlayer")
	end)
end

function KnitBadgeService:AwardBadge(player: Player, badgeId: string)
	assert(player ~= nil, "Player is missing or nil.")
	assert(badgeId ~= nil, "Badge ID is missing or nil.")
	assert(type(badgeId) == "string", `Badge ID must be string. Got {type(badgeId)}.`)

	local success, result = pcall(function()
		return RobloxBadgeService:UserHasBadgeAsync(player.UserId, self.BadgeIds[badgeId])
	end)

	if success then
		if result then
			return
		end
	else
		self.NotificationsService:new(player, {
			text = `Failed to check if you already have "{self.BadgeNames[badgeId]}" badge. BadgeService: {result}.`,
			title = "Error occurred while checking if you already have badge",
			duration = -1,
			type = "error",
		})

		return
	end

	success, result = pcall(function()
		return RobloxBadgeService:AwardBadge(player.UserId, self.BadgeIds[badgeId])
	end)

	if success then
		return self.NotificationsService:new(player, {
			text = `You are awarded with "{self.BadgeNames[badgeId]}" badge!`,
			title = "Badge awarded",
			duration = 30,
			type = "badgeAward",
		})
	else
		self.NotificationsService:new(player, {
			text = `Failed to award "{self.BadgeNames[badgeId]}" badge. BadgeService: {result}.`,
			title = "Error occurred while awarding badge",
			duration = -1,
			type = "error",
		})

		return
	end
end

return KnitBadgeService
