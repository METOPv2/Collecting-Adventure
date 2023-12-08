-- Services
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
}

-- Settings service
local SettingsService = Knit.CreateService({
	Name = "SettingsService",
	Settings = { "NotificationsEnabled", "MusicEnabled", "SFXEnabled", "MusicVolume", "SFXVolume" },
	Client = {
		SettingChanged = Knit.CreateSignal(),
	},
	SettingChanged = Signal.new(),
})

function SettingsService:KnitInit()
	self.PlayerDataService = Knit.GetService("PlayerDataService")
end

function SettingsService:SetSetting(player: Player, key: string, value: any)
	assert(player ~= nil, "Player is missing or nil.")
	assert(key ~= nil, "Player is missing or nil.")
	assert(value ~= nil, "Value is missing or nil.")

	self.PlayerDataService:SetAsync(player, key, value)
	self.SettingChanged:Fire(player, key, value)
	self.Client.SettingChanged:Fire(player, key, value)
end

function SettingsService.Client:SetSetting(player: Player, key: string, value: any)
	self.Server:SetSetting(player, key, value)
end

function SettingsService:GetSettings(player: Player): Settings
	local playerSettings = {}
	for _, setting in ipairs(self.Settings) do
		playerSettings[setting] = self.PlayerDataService:GetAsync(player, setting)
	end
	return playerSettings
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
