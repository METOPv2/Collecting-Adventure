-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Add knit controllers
local controllers: Folder = ReplicatedStorage.Source.Controllers
for _, v in ipairs(controllers:GetDescendants()) do
	if v:IsA("ModuleScript") and v.Name:match("Controller$") then
		require(v)
	end
end

-- Start knit on client
Knit.Start():catch(warn)
