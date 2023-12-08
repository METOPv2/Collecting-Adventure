-- Serivces
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

-- Teleport controller
local TeleportController = Knit.CreateController({
	Name = "TeleportController",
	Initializing = true,
	Initialized = Signal.new(),
})

function TeleportController:KnitInit()
	self.TeleportService = Knit.GetService("TeleportService")

	self.TeleportService
		:GetSpawnpoints()
		:andThen(function(spawnpoints)
			self.Spawnpoints = spawnpoints
		end)
		:catch(warn)
		:await()

	self.Initializing = false
	self.Initialized:Fire()
end

function TeleportController:Teleport(spawnpoint: string)
	assert(spawnpoint ~= nil, "Spawnpoint is missing or nil.")
	self.TeleportService:Teleport(spawnpoint):catch(warn)
end

function TeleportController:GetSpawnpoints(): {}
	return self.Spawnpoints
end

return TeleportController
