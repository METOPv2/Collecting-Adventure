-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
