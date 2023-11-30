-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

-- Types
type Settings = {
	NotificationsEnabled: boolean,
	MusicEnabled: boolean,
	SFXEnabled: boolean,
	MusicVolume: number,
	SFXVolume: number,
}

-- Settings controller
local SettingsController = Knit.CreateController({
	Name = "SettingsController",
	SettingChanged = Signal.new(),
	Initializing = true,
	Initialized = Signal.new(),
})

function SettingsController:KnitInit()
	self.SettingsService = Knit.GetService("SettingsService")

	self.SettingsNames = {
		NotificationsEnabled = "Notifications Enabled",
		MusicEnabled = "Music Enabled",
		SFXEnabled = "SFX Enabled",
		MusicVolume = "Music Volume",
		SFXVolume = "SFX Volume",
	}

	self.SettingsService
		:GetSettings()
		:andThen(function(playerSettings)
			self.Settings = playerSettings
		end)
		:catch(warn)
		:await()

	self.SettingsService.SettingChanged:Connect(function(setting: string, value: any)
		self.Settings[setting] = value
		self.SettingChanged:Fire(setting, value)
	end)

	self.Initializing = false
	self.Initialized:Fire()
end

function SettingsController:SetSetting(key: string, value: any)
	assert(key ~= nil, "Key is missing or nil.")
	assert(value ~= nil, "Value is missing or nil.")
	self.SettingsService:SetSetting(key, value)
end

function SettingsController:GetSetting(key: string): any
	assert(key ~= nil, "Key is missing or nil.")

	if self.Initializing then
		self.Initialized:Wait()
	end

	return self.Settings[key]
end

function SettingsController:GetSettings(): Settings
	if self.Initializing then
		self.Initialized:Wait()
	end

	return self.Settings
end

return SettingsController
