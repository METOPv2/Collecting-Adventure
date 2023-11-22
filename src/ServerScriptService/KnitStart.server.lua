-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Add knit services
local services: Folder = ServerStorage.Source.Services
for _, v in ipairs(services:GetDescendants()) do
	if v:IsA("ModuleScript") and v.Name:match("Service$") then
		require(v)
	end
end

-- Start knit on server
Knit.Start():catch(warn)
