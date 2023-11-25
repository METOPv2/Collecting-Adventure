-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

-- Player data controller
local PlayerDataController = Knit.CreateController({
	Name = "PlayerDataController",
	DataChanged = Signal.new(),
	Initialized = Signal.new(),
})

function PlayerDataController:KnitInit()
	self.PlayerDataService = Knit.GetService("PlayerDataService")

	self.PlayerDataService
		:GetPlayerData()
		:andThen(function(playerData)
			self.MyData = playerData
			self.Initialized:Fire()
			self.PlayerDataService.DataChanged:Connect(function(key: any, value: any, oldValue: any)
				self.MyData[key] = value
				self.DataChanged:Fire(key, value, oldValue)
			end)
		end)
		:catch(warn)
end

function PlayerDataController:GetPlayerData(): any
	if self.MyData == nil then
		self.Initialized:Wait()
	end

	return self.MyData
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

function PlayerDataController:InsertTableAsync(key: any, value: {})
	assert(key, "Key is missing or nil.")
	assert(value, "Value is missing or nil.")
	assert(
		type(self:GetPlayerData()[key]) == "number",
		`Cannot insert table in {type(self:GetPlayerData()[key])} data type. Table only.`
	)
	assert(type(value) == "table", `Value must be table. Got {type(value)}.`)
	self.PlayerDataService:InsertTableAsync(key, value):catch(warn)
end

function PlayerDataController:RemoveTableAsync(key: any, value: {})
	assert(key, "Key is missing or nil.")
	assert(value, "Value is missing or nil.")
	assert(
		type(self:GetPlayerData()[key]) == "number",
		`Cannot remove table from {type(self:GetPlayerData()[key])} data type. Table only.`
	)
	assert(type(value) == "table", `Value must be table. Got {type(value)}.`)
	self.PlayerDataService:RemoveTableAsync(key, value):catch(warn)
end

return PlayerDataController
