-- Serivces
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

-- Teleport controller
local TeleportController = Knit.CreateController({
	Name = "TeleportController",
})

function TeleportController:KnitInit()
	self.MonetizationController = Knit.GetController("MonetizationController")
	self.TeleportService = Knit.GetService("TeleportService")
	self.NotificationsController = Knit.GetController("NotificationsController")

	self.TeleportService
		:GetSpawnpoints()
		:andThen(function(spawnpoints)
			self.Spawnpoints = spawnpoints
		end)
		:catch(warn)
end

function TeleportController:Teleport(spawnpoint: string)
	assert(spawnpoint ~= nil, "Spawnpoint is missing.")
	local ownGamepass = false
	self.MonetizationController
		:DoOwnGamepass(671455721)
		:andThen(function(value)
			ownGamepass = value
		end)
		:catch(warn)
		:await()
	if ownGamepass then
		self.TeleportService:Teleport(spawnpoint):catch(warn)
	else
		self.NotificationsController:new({
			text = "You must own a teleport game pass to be able to teleport.",
			title = "Teleport game pass required",
			duration = 15,
			type = "warn",
		})
		self.MonetizationController:BuyGamepass(671455721):catch(warn)
	end
end

function TeleportController:GetSpawnpoints(): {}
	return self.Spawnpoints
end

return TeleportController
