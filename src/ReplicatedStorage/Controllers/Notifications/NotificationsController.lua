-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Roact = require(ReplicatedStorage:WaitForChild("Packages").roact)

-- Player
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Components
local NotificationComponent = require(ReplicatedStorage:WaitForChild("Source").Components.Notification)

-- Notifications controller
local NotificationsController = Knit.CreateController({
	Name = "NotificationsController",
	NotificationsEnabled = true,
})

function NotificationsController:KnitInit()
	self.GuiController = Knit.GetController("GuiController")
	self.NotificationsService = Knit.GetService("NotificationsService")
	self.SFXController = Knit.GetController("SFXController")
	self.SettingsController = Knit.GetController("SettingsController")
	self.PlayerDataController = Knit.GetController("PlayerDataController")

	self.NotificationsEnabled = self.SettingsController:GetSetting("NotificationsEnabled")

	self.SettingsController.SettingChanged:Connect(function(key: string, value: boolean)
		if key == "NotificationsEnabled" and self.NotificationsEnabled ~= value then
			self.NotificationsEnabled = value
		end
	end)

	self.NotificationsService.new:Connect(
		function(data: { text: string, title: string, duration: number, type: string? })
			self:new(data)
		end
	)

	if (workspace:GetServerTimeNow() - self.PlayerDataController:GetAsync("FirstJoin")) > 60 then
		self:new({ text = "Welcome to Collecting Adventure!", title = "Welcome back!", duration = 15 })
	end
end

function NotificationsController:new(data: { text: string, title: string, duration: number, type: string? }): {}
	assert(data, "Data is missing or nil.")
	assert(data.text, "Text is missing or nil.")
	assert(data.title, "Title is missing or nil.")
	assert(data.duration, "Duration is missing or nil.")
	assert(typeof(data.duration) == "number", `Duration mush be number. Got {typeof(data.duration)}.`)
	if data.duration >= 0 then
		assert(data.duration >= 5, "Duration can't be lower than 5.")
	end

	if self.NotificationsEnabled == false then
		return
	end

	local holder = playerGui:FindFirstChild("Notifications") and playerGui.Notifications:FindFirstChild("Holder")
	if not holder then
		self.GuiController:OpenGui("Notifications", nil, { DontStoreInHistory = true, DontCloseIfAlreadyOpen = true })
		return self:new(data)
	end

	if data.type then
		if data.type == "error" then
			self.SFXController:PlaySFX("Error")
		elseif data.type == "warn" then
			self.SFXController:PlaySFX("Warning")
		elseif data.type == "info" then
			self.SFXController:PlaySFX("Notification")
		elseif data.type == "levelUp" then
			self.SFXController:PlaySFX("LevelUp")
		elseif data.type == "badgeAward" then
			self.SFXController:PlaySFX("BadgeAward")
		end
	end

	local transparency, updateTransparency = Roact.createBinding(1)
	data.transparency = transparency

	local number = Instance.new("NumberValue")
	number.Value = 1
	number.Changed:Connect(updateTransparency)

	local tree
	local closing = false
	data.closeUI = function()
		if tree and not closing then
			closing = true

			local tween = TweenService:Create(
				number,
				TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Value = 1 }
			)
			tween:Play()
			tween.Completed:Wait()

			Roact.unmount(tree)
			tree = nil
		end
	end

	local element = Roact.createElement(NotificationComponent, data)
	tree = Roact.mount(element, holder, "Notification")

	if data.duration >= 0 then
		task.delay(data.duration, data.closeUI)
	end

	TweenService:Create(number, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Value = 0 })
		:Play()

	return data.closeUI
end

return NotificationsController
