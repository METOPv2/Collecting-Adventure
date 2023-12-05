local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)

local FeedbackController = Knit.CreateController({
	Name = "FeedbackController",
})

function FeedbackController:KnitInit()
	self.FeedbackService = Knit.GetService("FeedbackService")
end

function FeedbackController:Send(data: { text: string })
	self.FeedbackService:Send(data)
end

return FeedbackController
