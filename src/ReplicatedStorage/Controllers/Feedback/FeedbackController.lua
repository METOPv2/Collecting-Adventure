local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

local FeedbackController = Knit.CreateController({
	Name = "FeedbackController",
})

function FeedbackController:KnitInit()
	self.FeedbackService = Knit.GetService("FeedbackService")
	self.NotificationsController = Knit.GetController("NotificationsController")
	self.PlayerDataController = Knit.GetController("PlayerDataController")

	self.FeedbackSentTime = self.PlayerDataController:GetAsync("FeedbackSentTime")
end

function FeedbackController:Send(data: { text: string })
	assert(data ~= nil, "Data is missing or nil.")
	assert(data.text ~= nil, "Text is missing or nil.")

	if data.text == "" then
		return self.NotificationsController:new({
			text = "Text can't be blank.",
			title = "Blank text",
			duration = 5,
		})
	end

	if workspace:GetServerTimeNow() - self.FeedbackSentTime < 60 then
		return self.NotificationsController:new({
			text = `You can send another feedback in {math.round(
				(60 - (workspace:GetServerTimeNow() - self.FeedbackSentTime)) * 10
			) / 10} seconds.`,
			title = "Too fast",
			duration = 10,
		})
	end

	self.FeedbackSentTime = workspace:GetServerTimeNow()
	self.FeedbackService:Send(data):catch(warn)
end

return FeedbackController
