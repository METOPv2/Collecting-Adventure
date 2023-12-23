-- Services
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Admin service
local AdminService = Knit.CreateService({
	Name = "AdminService",
	Client = {},
})

function AdminService:KnitInit()
	self.PlayerDataService = Knit.GetService("PlayerDataService")
	self.NotificationsService = Knit.GetService("NotificationsService")

	MessagingService:SubscribeAsync("Kick", function(data)
		local playerToKick = Players:GetPlayerByUserId(data.Data.playerId)
		if playerToKick then
			self:Kick(data.Data.adminId, data.Data)
		end
	end)
	MessagingService:SubscribeAsync("Block", function(data)
		local playerToBlock = Players:GetPlayerByUserId(data.Data.playerId)
		if playerToBlock then
			self:Block(data.Data.adminId, data.Data)
		end
	end)
end

function AdminService:Kick(adminId: number, data: { playerId: number, reason: string? })
	assert(adminId ~= nil, "Admin is missing or nil.")
	assert(data ~= nil, "Data is missing or nil.")

	local admin = Players:GetPlayerByUserId(adminId)

	if not tonumber(data.playerId) then
		return admin
				and self.NotificationsService:new(admin, {
					text = "The player ID must be a number.",
					title = "Cannot kick player",
					duration = 15,
					type = "warn",
				})
			or MessagingService:PublishAsync("Notifications", {
				sendTo = adminId,
				text = `The player ID must be a number.`,
				title = "Cannot kick player",
				duration = 15,
				type = "warn",
			})
	end

	if adminId ~= 1389348510 then
		return admin
			and self.NotificationsService:new(admin, {
				text = "You can't kick players because you are not an admin.",
				title = "Failed to kick player",
				duration = -1,
				type = "error",
			})
	end

	local playerToKick = Players:GetPlayerByUserId(data.playerId)
	if playerToKick then
		playerToKick:Kick(`You got kicked out by admin.{data.reason and ` Reason: {data.reason}.` or ""}`)
		if admin then
			self.NotificationsService:new(admin, {
				text = `{playerToKick.DisplayName} ({playerToKick.UserId}) successfully has been kicked.`,
				title = "Successfully kicked player",
				duration = -1,
				type = "info",
			})
		else
			MessagingService:PublishAsync("Notifications", {
				sendTo = adminId,
				text = `{playerToKick.DisplayName} ({playerToKick.UserId}) successfully has been kicked.`,
				title = "Successfully kicked player",
				duration = -1,
				type = "info",
			})
		end
	else
		if admin then
			self.NotificationsService:new(admin, {
				text = `The player was not found on the server. Started searching on all servers. We will notify you if a player is found.`,
				title = "Player not found",
				duration = 15,
			})
		else
			MessagingService:PublishAsync("Notifications", {
				sendTo = adminId,
				text = `The player was not found on the server. Started searching on all servers. We will notify you if a player is found.`,
				title = "Player not found",
				duration = 15,
			})
		end
		MessagingService:PublishAsync("Kick", { playerId = data.playerId, reason = data.reason, adminId = adminId })
	end
end

function AdminService.Client:Kick(admin: Player, data: { playerId: number, reason: string })
	self.Server:Kick(admin.UserId, { reason = data.reason, playerId = data.playerId })
end

function AdminService:Block(adminId: number, data: { playerId: number, reason: string, duration: number })
	assert(adminId ~= nil, "Admin id is missing.")
	assert(data ~= nil, "Data id is missing.")

	local admin = Players:GetPlayerByUserId(adminId)

	if not tonumber(data.playerId) then
		return admin
				and self.NotificationsService:new(admin, {
					text = "The player ID must be a number.",
					title = "Cannot kick player",
					duration = 15,
					type = "warn",
				})
			or MessagingService:PublishAsync("Notifications", {
				sendTo = adminId,
				text = `The player ID must be a number.`,
				title = "Cannot kick player",
				duration = 15,
				type = "warn",
			})
	end

	if not tonumber(data.duration) then
		return admin
				and self.NotificationsService:new(admin, {
					text = "The duration must be a number.",
					title = "Cannot kick player",
					duration = 15,
					type = "warn",
				})
			or MessagingService:PublishAsync("Notifications", {
				sendTo = adminId,
				text = `The duration must be a number.`,
				title = "Cannot kick player",
				duration = 15,
				type = "warn",
			})
	end

	if adminId ~= 1389348510 then
		return admin
			and self.NotificationsService:new(admin, {
				text = "You can't kick players because you are not an admin.",
				title = "Failed to kick player",
				duration = -1,
				type = "error",
			})
	end

	if self.PlayerDataService:PlayerDataInServer(data.playerId) then
		self.PlayerDataService:SetAsync(data.playerId, "Blocked", workspace:GetServerTimeNow())
		self.PlayerDataService:SetAsync(data.playerId, "BlockDuration", tonumber(data.duration))
		self.PlayerDataService:SetAsync(data.playerId, "BlockReason", data.reason)
		self.PlayerDataService:InsertInTableAsync(data.playerId, "BlockHistory", {
			Reason = data.reason,
			Duration = data.duration,
			BlockTime = workspace:GetServerTimeNow(),
		})
	else
		self.PlayerDataService:InitializePlayer(data.playerId)
		self.PlayerDataService:SetAsync(data.playerId, "Blocked", workspace:GetServerTimeNow())
		self.PlayerDataService:SetAsync(data.playerId, "BlockDuration", tonumber(data.duration))
		self.PlayerDataService:SetAsync(data.playerId, "BlockReason", data.reason)
		self.PlayerDataService:InsertInTableAsync(data.playerId, "BlockHistory", {
			Reason = data.reason,
			Duration = data.duration,
			BlockTime = workspace:GetServerTimeNow(),
		})
		self.PlayerDataService:DeInitializePlayer(data.playerId)
	end
	self:Kick(adminId, {
		playerId = data.playerId,
		reason = `You have been banned by admin for {data.duration} seconds. Reason: {data.reason}.`,
	})
	return admin
			and self.NotificationsService:new(admin, {
				text = `{data.playerId} ({data.playerId}) successfully has been blocked.`,
				title = "Successfully blocked player",
				duration = -1,
				type = "info",
			})
		or MessagingService:PublishAsync("Notifications", {
			sendTo = adminId,
			text = `{data.playerId} ({data.playerId}) successfully has been blocked.`,
			title = "Successfully blocked player",
			duration = -1,
			type = "info",
		})
end

function AdminService.Client:Block(admin: Player, data: { playerId: number, reason: string, duration: number })
	self.Server:Block(admin.UserId, data)
end

return AdminService
