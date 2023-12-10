-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

-- Admin controller
local AdminController = Knit.CreateController({
	Name = "AdminController",
})

function AdminController:KnitInit()
	self.AdminService = Knit.GetService("AdminService")
	self.NotificationsController = Knit.GetController("NotificationsController")
end

function AdminController:Kick(data: { playerId: number, reason: string? })
	assert(data ~= nil, "Data is missing or nil.")
	self.AdminService:Kick(data)
end

function AdminController:Block(data: { playerId: number, reason: string, duration: number })
	assert(data ~= nil, "Data is missing or nil.")
	self.AdminService:Block(data)
end

return AdminController
