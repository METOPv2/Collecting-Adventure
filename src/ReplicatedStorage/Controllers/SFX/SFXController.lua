-- Services
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

-- Music
local musicAssets: SoundGroup = SoundService:WaitForChild("Music")
local sfxAssets: SoundGroup = SoundService:WaitForChild("SFX")

-- SFX contoller
local SFXController = Knit.CreateController({
	Name = "SFXController",
	CurrentPlayingMusic = nil,
	MusicStartedPlaying = Signal.new(),
	MusicStoppedPlaying = Signal.new(),
	MusicConnections = {},
	SFXPlaying = Signal.new(),
	MusicEnabledChanged = Signal.new(),
	SFXEnabledChanged = Signal.new(),
	MusicEnabled = true,
	SFXEnabled = true,
})

function SFXController:KnitInit()
	self.SettingsController = Knit.GetController("SettingsController")
	self.SFXService = Knit.GetService("SFXService")

	self.MusicEnabled = self.SettingsController:GetSetting("MusicEnabled")
	self.SFXEnabled = self.SettingsController:GetSetting("SFXEnabled")

	self.SFXService.PlaySFX:Connect(function(sfx: string)
		self:PlaySFX(sfx)
	end)

	self.SettingsController.SettingChanged:Connect(function(key: string, value: any)
		if key == "MusicEnabled" then
			self:SetMusicEnabled(value)
		elseif key == "SFXEnabled" then
			self:SetSFXEnabled(value)
		elseif key == "SFXVolume" then
			self:SetSFXVolume(value)
		elseif key == "MusicVolume" then
			self:SetMusicVolume(value)
		end
	end)

	coroutine.wrap(function()
		while true do
			if not self.MusicEnabled then
				self.MusicEnabledChanged:Wait()
			end
			self:PlayMusic()
			self.MusicStoppedPlaying:Wait()
		end
	end)()
end

function SFXController:PlaySFX(sfx: string)
	assert(sfx ~= nil, "SFX is missing or nil.")

	if not self.SFXEnabled then
		return
	end

	sfx = sfxAssets:FindFirstChild(sfx)

	if not sfx then
		return
	else
		sfx = sfx:Clone()
		Debris:AddItem(sfx, sfx.TimeLength)
	end

	SoundService:PlayLocalSound(sfx)
	self.SFXPlaying:Fire(sfx)
end

function SFXController:SetMusicEnabled(value: boolean)
	assert(value ~= nil, "Value is missing or nil.")
	if self.MusicEnabled == value then
		return
	end
	self.MusicEnabled = value
	self.MusicEnabledChanged:Fire(value)
end

function SFXController:SetSFXEnabled(value: boolean)
	assert(value ~= nil, "Value is missing or nil.")
	if self.SFXEnabled == value then
		return
	end
	self.SFXEnabled = value
	self.SFXEnabledChanged:Fire(value)
end

function SFXController:PlayMusic(music: Sound?)
	self:StopCurrentPlayingMusic()

	if not self.MusicEnabled then
		return
	end

	if not music then
		music = musicAssets:GetChildren()[math.random(1, #musicAssets:GetChildren())]
	end

	self.CurrentPlayingMusic = music
	self.CurrentPlayingMusic:Play()
	self.MusicStartedPlaying:Fire()

	table.insert(
		self.MusicConnections,
		self.CurrentPlayingMusic.Ended:Connect(function(soundId)
			self:StopCurrentPlayingMusic()
		end)
	)

	table.insert(
		self.MusicConnections,
		self.MusicEnabledChanged:Connect(function()
			self:StopCurrentPlayingMusic()
		end)
	)
end

function SFXController:SetSFXVolume(volume: number)
	assert(volume ~= nil, "Volume is missing or nil.")
	assert(typeof(volume) == "number", `Volume must be number. Got {typeof(volume)}.`)

	sfxAssets.Volume = volume
end

function SFXController:SetMusicVolume(volume: number)
	assert(volume ~= nil, "Volume is missing or nil.")
	assert(typeof(volume) == "number", `Volume must be number. Got {typeof(volume)}.`)

	musicAssets.Volume = volume
end

function SFXController:StopCurrentPlayingMusic()
	if not self.CurrentPlayingMusic then
		return
	end

	for i, v: RBXScriptConnection in ipairs(self.MusicConnections) do
		v:Disconnect()
		self.MusicConnections[i] = nil
	end

	self.CurrentPlayingMusic:Stop()
	self.CurrentPlayingMusic = nil
	self.MusicStoppedPlaying:Fire()
end

return SFXController
