-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)

-- Prompt app
local function Prompt(props)
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	})
end

return Prompt
