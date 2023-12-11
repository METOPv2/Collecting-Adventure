-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)
local Signal = require(ReplicatedStorage.Packages.signal)

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
}

-- Settings service
local SettingsService = Knit.CreateService({
	Name = "SettingsService",
	Settings = {
		"NotificationsEnabled",
		"MusicEnabled",
		"SFXEnabled",
		"MusicVolume",
		"SFXVolume",
		"OpenUpdateLogOnStart",
		"WelcomeBackNotification",
		"CapacityPassEnabled",
		"WalkSpeedPassEnabled",
		"FruitPricePassEnabled",
	},
	Client = {
		SettingChanged = Knit.CreateSignal(),
	},
	SettingChanged = Signal.new(),
	PlayerSettings = {},
})

function SettingsService:KnitInit()
	self.PlayerDataService = Knit.GetService("PlayerDataService")

	for _, player in ipairs(Players:GetPlayers()) do
		coroutine.wrap(function()
			self.PlayerSettings[player.UserId] = {}
			for _, setting in ipairs(self.Settings) do
				self.PlayerSettings[player.UserId][setting] = self.PlayerDataService:GetAsync(player, setting)
			end
		end)()
	end

	Players.PlayerAdded:Connect(function(player)
		self.PlayerSettings[player.UserId] = {}
		for _, setting in ipairs(self.Settings) do
			self.PlayerSettings[player.UserId][setting] = self.PlayerDataService:GetAsync(player, setting)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		self.PlayerSettings[player.UserId] = nil
	end)
end

function SettingsService:SetSetting(player: Player, key: string, value: any)
	assert(player ~= nil, "Player is missing or nil.")
	assert(key ~= nil, "Player is missing or nil.")
	assert(value ~= nil, "Value is missing or nil.")

	self.PlayerSettings[player.UserId][key] = value
	self.PlayerDataService:SetAsync(player, key, value)
	self.SettingChanged:Fire(player, key, value)
	self.Client.SettingChanged:Fire(player, key, value)
end

function SettingsService.Client:SetSetting(player: Player, key: string, value: any)
	self.Server:SetSetting(player, key, value)
end

function SettingsService:GetSettings(player: Player): Settings
	return self.PlayerSettings[player.UserId]
end

function SettingsService:GetSetting(player: Player, setting: string): any
	return self.PlayerSettings[player.UserId][setting]
end

function SettingsService.Client:GetSettings(player: Player): Settings
	return self.Server:GetSettings(player)
end

function SettingsService:GetSFXVolume(player: Player): number
	assert(player ~= nil, "Player is missing or nil")
	return self.PlayerDataService:GetAsync(player, "SFXVolume")
end

function SettingsService:GetMusicVolume(player: Player): number
	assert(player ~= nil, "Player is missing or nil")
	return self.PlayerDataService:GetAsync(player, "MusicVolume")
end

function SettingsService.Client:GetSFXVolume(player: Player): number
	return self.Server:GetSFXVolume(player)
end

function SettingsService.Client:GetMusicVolume(player: Player): number
	return self.Server:GetMusicVolume(player)
end

return SettingsService
