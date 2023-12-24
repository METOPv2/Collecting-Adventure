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
	OpenUpdateLogOnStart: boolean,
	WelcomeBackNotification: boolean,
	CapacityPassEnabled: boolean,
	WalkSpeedPassEnabled: boolean,
	FruitPricePassEnabled: boolean,
	LowPerformanceMode: boolean,
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
		OpenUpdateLogOnStart = "Open Update Log on Start",
		WelcomeBackNotification = `"Welcome Back" Notification`,
		CapacityPassEnabled = "Capacity pass enabled",
		WalkSpeedPassEnabled = "Walk speed pass enabled",
		FruitPricePassEnabled = "Fruit price pass enabled",
		LowPerformanceMode = "Low performance mode",
	}

	self.SettingsService
		:GetSettings()
		:andThen(function(playerSettings)
			self.Settings = playerSettings
		end)
		:catch(warn)
		:await()

	self.SettingsService
		:GetSFXVolume()
		:andThen(function(sfxVolume)
			self.SFXVolume = sfxVolume
		end)
		:catch(warn)
		:await()

	self.SettingsService
		:GetMusicVolume()
		:andThen(function(musicVolume)
			self.MusicVolume = musicVolume
		end)
		:catch(warn)
		:await()

	self.SettingsService.SettingChanged:Connect(function(key, value)
		self.Settings[key] = value
		self.SettingChanged:Fire(key, value)
		if key == "SFXVolume" then
			self.SFXVolume = value
		elseif key == "MusicVolume" then
			self.MusicVolume = value
		end
	end)

	self.Initializing = false
	self.Initialized:Fire()
end

function SettingsController:GetSettingName(setting: string): string
	return self.SettingsNames[setting]
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

function SettingsController:GetMusicVolume(): number
	if self.Initializing then
		self.Initialized:Wait()
	end

	return self.MusicVolume
end

function SettingsController:GetSFXVolume(): number
	if self.Initializing then
		self.Initialized:Wait()
	end

	return self.SFXVolume
end

return SettingsController
