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
Knit.Start()
	:andThen(function()
		-- Load apps
		local apps = ReplicatedStorage.Source.Apps
		for _, app in ipairs(apps:GetDescendants()) do
			if app:IsA("ModuleScript") then
				require(app)
			end
		end

		-- Load components
		local components = ReplicatedStorage.Source.Components
		for _, component in ipairs(components:GetDescendants()) do
			if component:IsA("ModuleScript") then
				require(component)
			end
		end

		-- Services
		local GUIController = Knit.GetController("GUIController")

		-- Initialize main app
		GUIController:OpenGUI("Main", nil, { DontStoreInHistory = true, DontCloseIfAlreadyOpen = true })
	end)
	:catch(warn)
