-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

-- Player
local localPlayer = Players.LocalPlayer

-- Player data controller
local PlayerDataController = Knit.CreateController({
	Name = "PlayerDataController",
	DataChanged = Signal.new(),
	NotLocalDataChanged = Signal.new(),
	Initialized = Signal.new(),
	Initializing = true,
})

function PlayerDataController:KnitInit()
	self.PlayerDataService = Knit.GetService("PlayerDataService")

	self.PlayerDataService
		:GetPlayerData()
		:andThen(function(playerData)
			self.MyData = playerData
			self.Initialized:Fire()
			self.PlayerDataService.DataChanged:Connect(function(player: Player, key: any, value: any, oldValue: any)
				if player == localPlayer then
					self.MyData[key] = value
					self.DataChanged:Fire(key, value, oldValue)
				else
					self.NotLocalDataChanged:Fire(player, key, value, oldValue)
				end
			end)
		end)
		:catch(warn)
		:await()
	self.Initializing = false
	self.Initialized:Fire()
end

function PlayerDataController:GetPlayerData(playerId: number?)
	if self.Initializing then
		self.Initialized:Fire()
	end
	if not playerId then
		if self.MyData == nil then
			self.Initialized:Wait()
		end

		return self.MyData
	else
		local playerData
		self.PlayerDataService
			:GetPlayerData(playerId)
			:andThen(function(value)
				playerData = value
			end)
			:catch(warn)
			:await()
		return playerData
	end
end

function PlayerDataController:GetAsync(key: any): any
	assert(key, "Key is missing or nil.")

	if self.MyData == nil then
		self.Initialized:Wait()
	end

	return self.MyData[key]
end

function PlayerDataController:SetAsync(key: any, value: any)
	assert(key, "Key is missing or nil.")
	assert(value, "Value is missing or nil.")
	self.PlayerDataService:SetAsync(key, value):catch(warn)
end

function PlayerDataController:IncrementAsync(key: any, value: number)
	assert(key, "Key is missing or nil.")
	assert(value, "Value is missing or nil.")
	assert(
		type(self:GetPlayerData()[key]) == "number",
		`Cannot increment {type(self:GetPlayerData()[key])} data type. Number only.`
	)
	assert(type(value) == "number", `Value must be number. Got {type(value)}.`)
	self.PlayerDataService:IncrementAsync(key, value):catch(warn)
end

function PlayerDataController:InsertInTableAsync(key: any, value: {})
	assert(key, "Key is missing or nil.")
	assert(value, "Value is missing or nil.")
	assert(
		type(self:GetPlayerData()[key]) == "number",
		`Cannot insert table in {type(self:GetPlayerData()[key])} data type. Table only.`
	)
	self.PlayerDataService:InsertInTableAsync(key, value):catch(warn)
end

function PlayerDataController:RemoveAsync(key: any, value: {})
	assert(key, "Key is missing or nil.")
	assert(value, "Value is missing or nil.")

	self.PlayerDataService:RemoveAsync(key, value):catch(warn)
end

return PlayerDataController
