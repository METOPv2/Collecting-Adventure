-- Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Feedback service
local FeedbackService = Knit.CreateService({
	Name = "FeedbackService",
	FeedbackSentDelayTime = 60,
	Webhook = "https://discord.com/api/webhooks/1144875257346412574/SAO18VprUdGrJAGRfITJrKr1x2OyZ558fne1KY7F7TOU_g70Bepkx7_GWmTPEmd3-nxO",
})

function FeedbackService:KnitInit()
	self.PlayerDataService = Knit.GetService("PlayerDataService")
	self.NotificationsService = Knit.GetService("NotificationsService")
	self.GuiService = Knit.GetService("GuiService")
end

function FeedbackService:KnitStart()
	for _, v: Model in ipairs(workspace.Feedback:GetChildren()) do
		v.PrimaryPart.ProximityPrompt.Triggered:Connect(function(playerWhoTriggered: Player)
			self.GuiService:OpenGui(playerWhoTriggered, "Feedback", nil, { CloseItSelf = true })
		end)
	end
end

function FeedbackService:Send(player: Player, data: { text: string })
	assert(player ~= nil, "Player is missing or nil.")
	assert(data ~= nil, "Data is missing or nil.")
	assert(data.text ~= nil, "Text is missing or nil.")

	if
		(workspace:GetServerTimeNow() - self.PlayerDataService:GetAsync(player, "FeedbackSentTime"))
		< self.FeedbackSentDelayTime
	then
		return self.NotificationsService:new(player, {
			text = string.format(
				"You can send another feedback after %d seconds.",
				self.FeedbackSentDelayTime
					- (workspace:GetServerTimeNow() - self.PlayerDataService:GetAsync(player, "FeedbackSentTime"))
			),
			title = "Slow down",
			type = "error",
			duration = 10,
		})
	end

	local feedbackData = {
		content = data.text,
		username = `{player.DisplayName}, {player.UserId}.`,
	}

	local encodedFeedbackData = HttpService:JSONEncode(feedbackData)

	HttpService:PostAsync(self.Webhook, encodedFeedbackData)

	self.PlayerDataService:SetAsync(player, "FeedbackSentTime", workspace:GetServerTimeNow())

	self.NotificationsService:new(player, {
		text = "Thanks for feedback!",
		title = "Feedback sent",
		type = "info",
		duration = 10,
	})
end

function FeedbackService.Client:Send(player: Player, data: { text: string })
	self.Server:Send(player, data)
end

return FeedbackService