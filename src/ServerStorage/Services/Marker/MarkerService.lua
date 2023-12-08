-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Types
type Settings = {
	Key: string,
}

-- MarkerService
local MarkerService = Knit.CreateService({
	Name = "MarkerService",
	Client = {
		New = Knit.CreateSignal(),
		MarkFinished = Knit.CreateSignal(),
	},
})

function MarkerService:New(player: Player, point: Vector3, settings: Settings)
	assert(player ~= nil, "Player is missing or nil.")
	assert(point ~= nil, "Point is missing or nil.")
	assert(settings ~= nil, "Setitngs is missing or nil.")
	assert(settings.Key ~= nil, "Key is missing or nil.")
	self.Client.New:Fire(player, point, settings)
end

function MarkerService:GetClosestPoint(player: Player, holder: Instance): Vector3
	local closest

	for _, part: Part in ipairs(holder:GetDescendants()) do
		if part.ClassName ~= "Part" and part.ClassName ~= "MeshPart" then
			continue
		end

		if not closest or player:DistanceFromCharacter(part.Position) < player:DistanceFromCharacter(closest) then
			closest = part.Position
		end
	end

	return closest
end

return MarkerService
