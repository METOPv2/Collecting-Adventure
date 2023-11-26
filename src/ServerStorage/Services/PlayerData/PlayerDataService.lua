-- Services
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)
local Signal = require(ReplicatedStorage.Packages.signal)

-- Data base
local PlayerDataBase = DataStoreService:GetDataStore("PlayerData")

-- Types
export type PlayerData = {
	Fruits: {},
	Bags: {},
	Xp: number,
	Level: number,
	EquippedBag: string,
	FruitBucks: number,
	Visits: number,
	FirstJoin: number,
	LeaveTime: number,
}

export type DataOptions = {
	HiddenFromClient: boolean,
}

-- Knit player data service
local PlayerDataService = Knit.CreateService({
	Name = "PlayerDataService",
	SessionDataBase = {},
	BlockedDataForClient = {},
	AllowedDataFromClient = {},
	Template = {
		Fruits = {},
		Bags = { "Pockets" },
		Xp = 0,
		Level = 0,
		EquippedBag = "",
		FruitBucks = 0,
		Visits = 0,
		FirstJoin = workspace:GetServerTimeNow(),
		LeaveTime = 0,
	},
	Client = {
		DataChanged = Knit.CreateSignal(),
	},
	SaveOnStudio = false,
	DataChanged = Signal.new(),
	InitializedPlayer = Signal.new(),
	DeinitializedPlayer = Signal.new(),
})

function PlayerDataService:KnitInit()
	for _, player in ipairs(Players:GetPlayers()) do
		coroutine.wrap(self.InitializedPlayer)(self, player)
	end

	Players.PlayerAdded:Connect(function(player)
		self:InitializePlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:DeinitializePlayer(player)
	end)

	game:BindToClose(function()
		while next(self.SessionDataBase) do
			self.DeinitializedPlayer:Wait()
		end
	end)
end

function PlayerDataService:Reconcile(template: { [any]: any }, data: { [any]: any }): { [any]: any }
	assert(template ~= nil, "Template is missing or nil.")
	assert(typeof(template) == "table", `Template must be table. Got {typeof(template)}.`)
	assert(data ~= nil, "Data is missing or nil.")
	assert(typeof(data) == "table", `Data must be table. Got {typeof(data)}.`)

	for key, value in pairs(template) do
		if data[key] == nil then
			data[key] = value
		elseif typeof(data[key]) == "table" then
			data[key] = self:Reconcile(value, data[key])
		end
	end

	return data
end

function PlayerDataService:InitializePlayer(player: Player)
	assert(player ~= nil, "Player is missing or nil.")
	assert(typeof(player) == "Instance", `Player type must be Instance. Got {typeof(player)}.`)
	assert(player.ClassName == "Player", `Player class name must be Player. Got {player.ClassName}.`)

	local playerId = tostring(player.UserId)
	local success: boolean, playerData: PlayerData | string = pcall(PlayerDataBase.GetAsync, PlayerDataBase, playerId)

	if success then
		if playerData == nil then
			playerData = self.Template
		else
			playerData = self:Reconcile(self.Template, playerData)
		end

		playerData.Visits += 1

		self.SessionDataBase[playerId] = playerData
		self.InitializedPlayer:Fire(player)
	else
		warn(`Failed to get data. Error: {playerData}.`)
	end
end

function PlayerDataService:DeinitializePlayer(player: Player)
	assert(player ~= nil, "Player is missing or nil.")
	assert(typeof(player) == "Instance", `Player type must be Instance. Got {typeof(player)}.`)
	assert(player.ClassName == "Player", `Player class name must be Player. Got {player.ClassName}.`)

	local playerId = tostring(player.UserId)
	local playerData: PlayerData = self.SessionDataBase[playerId]

	if playerData == nil then
		return
	end

	local success: boolean, errorMessage: string?

	if self.SaveOnStudio then
		success, errorMessage = pcall(PlayerDataBase.SetAsync, PlayerDataBase, playerId, playerData)
	else
		success = true
	end

	if success then
		self.SessionDataBase[playerId].LeaveTime = workspace:GetServerTimeNow()
		self.SessionDataBase[playerId] = nil
		self.DeinitializedPlayer:Fire(player)
	else
		warn(`Failed to save data. Error: {errorMessage}`)
	end
end

function PlayerDataService:GetPlayerData(player: Player): PlayerData?
	assert(player ~= nil, "Player is missing or nil.")
	assert(typeof(player) == "Instance", `Player type must be Instance. Got {typeof(player)}.`)
	assert(player.ClassName == "Player", `Player class name must be Player. Got {player.ClassName}.`)

	local playerId = tostring(player.UserId)
	local playerData = self.SessionDataBase[playerId]

	if playerData == nil then
		repeat
			self.InitializedPlayer:Wait()
			playerData = self.SessionDataBase[playerId]
		until playerData
	end

	return playerData
end

function PlayerDataService.Client:GetPlayerData(player: Player): PlayerData?
	local playerData = self.Server:GetPlayerData(player)

	for key, _ in pairs(playerData) do
		if table.find(self.Server.BlockedDataForClient, key) then
			playerData[key] = nil
		end
	end

	return playerData
end

function PlayerDataService:GetAsync(player: Player, key: any): any?
	assert(player ~= nil, "Player is missing or nil.")
	assert(typeof(player) == "Instance", `Player type must be Instance. Got {typeof(player)}.`)
	assert(player.ClassName == "Player", `Player class name must be Player. Got {player.ClassName}.`)
	assert(key ~= nil, "Key is missing or nil.")

	local playerId = tostring(player.UserId)
	local playerData = self.SessionDataBase[playerId]

	if playerData == nil then
		repeat
			self.InitializedPlayer:Wait()
			playerData = self.SessionDataBase[playerId]
		until playerData
	end

	return playerData[key]
end

function PlayerDataService.Client:GetAsync(player: Player, key: any): any?
	assert(not table.find(self.Server.BlockedDataForClient, key), `{player.Name} have no access to read "{key}" key.`)

	return self.Server:GetAsync(player, key)
end

function PlayerDataService:SetAsync(player: Player, key: any, value: any, options: DataOptions?)
	assert(player ~= nil, "Player is missing or nil.")
	assert(typeof(player) == "Instance", `Player type must be Instance. Got {typeof(player)}.`)
	assert(player.ClassName == "Player", `Player class name must be Player. Got {player.ClassName}.`)
	assert(key ~= nil, "Key is missing or nil.")
	assert(value ~= nil, "Value is missing or nil.")
	assert(value == value, `Value might be nan. Value: "{value}".`)
	local dataType = typeof(self:GetAsync(player, key))
	local valueType = typeof(value)
	assert(dataType == valueType, `Got wrong data type. Must be "{dataType}", got "{valueType}".`)

	local playerId = tostring(player.UserId)

	if self.SessionDataBase[playerId] == nil then
		repeat
			self.InitializedPlayer:Wait()
		until self.SessionDataBase[playerId]
	end

	local previousValue = self.SessionDataBase[playerId][key]

	self.SessionDataBase[playerId][key] = value
	self.DataChanged:Fire(player, key, self.SessionDataBase[playerId][key], previousValue)

	if not table.find(self.BlockedDataForClient, key) or (options and not options.HiddenFromClient) then
		self.Client.DataChanged:Fire(player, key, self.SessionDataBase[playerId][key], previousValue)
	end
end

function PlayerDataService.Client:SetAsync(player: Player, key: any, value: any)
	assert(
		table.find(self.Server.AllowedDataFromClient, key),
		`{player.Name} have no access to save data in "{key}" key.`
	)

	self.Server:SetAsync(player, key, value)
end

function PlayerDataService:IncrementAsync(player: Player, key: any, value: number, options: DataOptions?)
	assert(player ~= nil, "Player is missing or nil.")
	assert(typeof(player) == "Instance", `Player type must be Instance. Got {typeof(player)}.`)
	assert(player.ClassName == "Player", `Player class name must be Player. Got {player.ClassName}.`)
	assert(key ~= nil, "Key is missing or nil.")
	assert(value ~= nil, "Value is missing or nil.")
	assert(value == value, `Value might be nan. Value: "{value}".`)
	local valueType = typeof(value)
	local dataType = typeof(self:GetAsync(player, key))
	assert(valueType == "number", `Value must be number. Got "{valueType}".`)
	assert(dataType == "number", `Cannot increment "{dataType}" type. Only number type can be incremented.`)

	local playerId = tostring(player.UserId)
	local previousValue = self.SessionDataBase[playerId][key]

	if self.SessionDataBase[playerId] == nil then
		repeat
			self.InitializedPlayer:Wait()
		until self.SessionDataBase[playerId]
	end

	self.SessionDataBase[playerId][key] += value
	self.DataChanged:Fire(player, key, self.SessionDataBase[playerId][key], previousValue)

	if not table.find(self.BlockedDataForClient, key) or (options and not options.HiddenFromClient) then
		self.Client.DataChanged:Fire(player, key, self.SessionDataBase[playerId][key], previousValue)
	end
end

function PlayerDataService.Client:IncrementAsync(player: Player, key: any, value: number)
	assert(
		table.find(self.Server.AllowedDataFromClient, key),
		`{player.Name} have no access to save data in "{key}" key.`
	)

	self.Server:IncrementAsync(player, key, value)
end

function PlayerDataService:InsertInTableAsync(
	player: Player,
	key: any,
	value: { any } | { [any]: any },
	options: DataOptions?
)
	assert(player ~= nil, "Player is missing or nil.")
	assert(typeof(player) == "Instance", `Player type must be Instance. Got {typeof(player)}.`)
	assert(player.ClassName == "Player", `Player class name must be Player. Got {player.ClassName}.`)
	assert(key ~= nil, "Key is missing or nil.")
	assert(value ~= nil, "Value is missing or nil.")
	assert(value == value, `Value may be nan. Value: "{value}".`)
	local dataInkey = self:GetAsync(player, key)
	local dataType = typeof(dataInkey)
	assert(dataType == "table", `Cannot insert table in "{dataType}" data.`)

	local playerId = tostring(player.UserId)

	if self.SessionDataBase[playerId] == nil then
		repeat
			self.InitializedPlayer:Wait()
		until self.SessionDataBase[playerId]
	end

	local previousValue = table.clone(dataInkey)

	table.insert(self.SessionDataBase[playerId][key], value)
	self.DataChanged:Fire(player, key, self:GetAsync(player, key), previousValue)

	if not table.find(self.BlockedDataForClient, key) or (options and not options.HiddenFromClient) then
		self.Client.DataChanged:Fire(player, key, self:GetAsync(player, key), previousValue)
	end
end

function PlayerDataService.Client:InsertInTableAsync(player: Player, key: any, value: any)
	assert(table.find(self.Server.AllowedDataFromClient, key), `{player.Name} have no access to save data in {key}.`)

	self.Server:InsertInTableAsync(player, key, value)
end

function PlayerDataService:RemoveAsync(player: Player, key: any, value: any?, options: DataOptions?)
	assert(player, "Player is missing or nil.")
	assert(typeof(player) == "Instance", `Player type must be Instance. Got {typeof(player)}.`)
	assert(player.ClassName == "Player", `Player class name must be Player. Got {player.ClassName}.`)
	assert(key, "Key is missing or nil.")
	assert(value, "Table is missing or nil.")
	assert(value == value, `Table may be nan. Table: "{value}".`)
	local valueType = typeof(value)
	local dataInkey = self:GetAsync(player, key)
	local dataType = typeof(dataInkey)
	assert(dataType == "table", `Cannot remove data from {dataType}. Table only.`)

	local playerId = tostring(player.UserId)

	if self.SessionDataBase[playerId] == nil then
		repeat
			self.InitializedPlayer:Wait()
		until self.SessionDataBase[playerId]
	end

	if value == nil then
		return self:SetAsync(player, key, nil)
	end

	for i, t in pairs(dataInkey) do
		if valueType == "table" and typeof(t) == valueType and #t == #value then
			local same = true

			for k, v in pairs(t) do
				if value[k] ~= v and same then
					same = false
				end
			end

			if same then
				local oldValue = table.clone(dataInkey)

				self.SessionDataBase[playerId][key][i] = nil
				self.DataChanged:Fire(player, key, self:GetAsync(player, key), oldValue)

				if not table.find(self.BlockedDataForClient, key) or (options and not options.HiddenFromClient) then
					self.Client.DataChanged:Fire(player, key, self:GetAsync(player, key), oldValue)
				end

				break
			end
		elseif valueType ~= "table" and typeof(t) == valueType and value == t then
			local oldValue = table.clone(self:GetAsync(player, key))

			self.SessionDataBase[playerId][key][i] = nil
			self.DataChanged:Fire(player, key, self:GetAsync(player, key), oldValue)

			if not table.find(self.BlockedDataForClient, key) or (options and not options.HiddenFromClient) then
				self.Client.DataChanged:Fire(player, key, self:GetAsync(player, key), oldValue)
			end
		end
	end
end

function PlayerDataService.Client:RemoveAsync(player: Player, key: any, value: any)
	assert(table.find(self.Server.AllowedDataFromClient, key), `{player.Name} have no access to save data in {key}.`)

	self.Server:RemoveAsync(player, key, value)
end

return PlayerDataService
