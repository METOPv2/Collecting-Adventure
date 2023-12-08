-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Teleport service
local TeleportService = Knit.CreateService({
	Name = "TeleportService",
	Client = {},
	Spawnpoints = require(script.Parent.Spawnpoints),
	InitializedPlayers = {},
})

function TeleportService:KnitInit()
	self.PlayerDataService = Knit.GetService("PlayerDataService")
end

function TeleportService:KnitStart()
	for _, player in ipairs(Players:GetPlayers()) do
		coroutine.wrap(function()
			self:InitializePlayer(player)
		end)()
	end

	Players.PlayerAdded:Connect(function(player)
		self:InitializePlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:DeinitializePlayer(player)
	end)

	for _, spawnpoint in ipairs(workspace.Spawnpoints:GetChildren()) do
		spawnpoint.Touched:Connect(function(otherPart: Part)
			local character = otherPart.Parent
			local player = Players:GetPlayerFromCharacter(character)
			if player then
				self.PlayerDataService:SetAsync(player, "Spawnpoint", spawnpoint.Name)
			end
		end)
	end
end

function TeleportService:InitializePlayer(player: Player)
	local connections = {}

	if player.Character then
		self:Teleport(player, self.PlayerDataService:GetAsync(player, "Spawnpoint"))
	end

	connections[1] = player.CharacterAdded:Connect(function()
		self:Teleport(player, self.PlayerDataService:GetAsync(player, "Spawnpoint"))
	end)

	self.InitializedPlayers[player.UserId] = { connections = connections }
end

function TeleportService:DeinitializePlayer(player: Player)
	if self.InitializedPlayers[player.UserId] then
		for _, connection: RBXScriptConnection in ipairs(self.InitializedPlayers[player.UserId].connections) do
			connection:Disconnect()
		end

		self.InitializedPlayers[player.UserId] = nil
	end
end

function TeleportService:Teleport(player: Player, spawnpoint: string)
	assert(player ~= nil, "Player is missing or nil.")
	assert(spawnpoint ~= nil, "Spawnpoint is missing or nil.")

	if not player.Character then
		player.CharacterAdded:Wait()
	end

	if not player:HasAppearanceLoaded() then
		player.CharacterAppearanceLoaded:Wait()
	end

	task.defer(function()
		local character = player.Character
		local spawnpontPart: Part = workspace.Spawnpoints:FindFirstChild(spawnpoint)

		character:PivotTo(CFrame.new(spawnpontPart.Position) * CFrame.new(0, character:GetExtentsSize().Y / 2, 0))
	end)
end

function TeleportService.Client:Teleport(player: Player, spawnpoint: string)
	self.Server:Teleport(player, spawnpoint)
end

function TeleportService:GetSpawnpoints(): {}
	return self.Spawnpoints
end

function TeleportService.Client:GetSpawnpoints(): {}
	return self.Server:GetSpawnpoints()
end

return TeleportService
