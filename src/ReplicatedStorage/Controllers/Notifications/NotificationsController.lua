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
	self.GUIController = Knit.GetController("GUIController")
	self.NotificationsService = Knit.GetService("NotificationsService")
	self.SFXController = Knit.GetController("SFXController")
	self.SettingsController = Knit.GetController("SettingsController")

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
end

function NotificationsController:new(data: { text: string, title: string, duration: number, type: string? })
	assert(data, "Data is missing or nil.")
	assert(data.text, "Text is missing or nil.")
	assert(data.title, "Title is missing or nil.")
	assert(data.duration, "Duration is missing or nil.")
	assert(typeof(data.duration) == "number", `Duration mush be number. Got {typeof(data.duration)}.`)
	assert(data.duration >= 5, "Duration can't be lower than 5.")

	if self.NotificationsEnabled == false then
		return
	end

	local holder = playerGui:FindFirstChild("Notifications") and playerGui.Notifications:FindFirstChild("Holder")
	if not holder then
		self.GUIController:OpenGUI("Notifications", nil, { DontStoreInHistory = true, DontCloseIfAlreadyOpen = true })
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
		end
	end

	local transparency, updateTransparency = Roact.createBinding(1)
	data.transparency = transparency

	local number = Instance.new("NumberValue")
	number.Value = 1
	number.Changed:Connect(updateTransparency)

	local element = Roact.createElement(NotificationComponent, data)
	local tree = Roact.mount(element, holder, "Notification")
	task.delay(data.duration, Roact.unmount, tree)

	TweenService:Create(number, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Value = 0 })
		:Play()

	task.delay(data.duration - 1, function()
		TweenService:Create(number, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Value = 1 })
			:Play()
	end)
end

return NotificationsController
