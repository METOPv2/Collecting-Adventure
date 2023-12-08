local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

local NotificationsService = Knit.CreateService({
	Name = "NotificationsService",
	Client = {
		new = Knit.CreateSignal(),
	},
})

function NotificationsService:new(
	player: Player,
	data: { text: string, title: string, duration: number, type: string? }
)
	assert(player, "Player is missing or nil.")
	assert(data, "Data is missing or nil.")
	assert(data.text, "Text is missing or nil.")
	assert(data.title, "Title is missing or nil.")
	assert(data.duration, "Duration is missing or nil.")
	assert(typeof(data.duration) == "number", `Duration mush be number. Got {typeof(data.duration)}.`)
	if data.duration >= 0 then
		assert(data.duration >= 5, "Duration can't be lower than 5.")
	end
	self.Client.new:Fire(player, data)
end

return NotificationsService
