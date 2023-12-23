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
	self.NotificationsService = Knit.GetService("NotificationsService")
	self.MonetizationService = Knit.GetService("MonetizationService")
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
		self:DeInitializePlayer(player)
	end)

	for _, spawnpoint in ipairs(workspace.Spawnpoints:GetChildren()) do
		spawnpoint.Touched:Connect(function(otherPart: Part)
			local character = otherPart.Parent
			local player = Players:GetPlayerFromCharacter(character)
			if player and self.PlayerDataService:GetAsync(player, "Spawnpoint") ~= spawnpoint.Name then
				self.NotificationsService:new(player, {
					text = `Spawnpoint changed from "{self.PlayerDataService:GetAsync(player, "Spawnpoint")}" to "{spawnpoint.Name}".`,
					title = "Spawnpoint changed",
					duration = 10,
				})
				self.PlayerDataService:SetAsync(player, "Spawnpoint", spawnpoint.Name)
			end
		end)
	end
end

function TeleportService:InitializePlayer(player: Player)
	local connections = {}

	if player.Character then
		self:Teleport(player, self.PlayerDataService:GetAsync(player, "Spawnpoint"), { IgnoreGamepass = true })
	end

	connections[1] = player.CharacterAdded:Connect(function()
		self:Teleport(player, self.PlayerDataService:GetAsync(player, "Spawnpoint"), { IgnoreGamepass = true })
	end)

	self.InitializedPlayers[player.UserId] = { connections = connections }
end

function TeleportService:DeInitializePlayer(player: Player)
	if self.InitializedPlayers[player.UserId] then
		for _, connection: RBXScriptConnection in ipairs(self.InitializedPlayers[player.UserId].connections) do
			connection:Disconnect()
		end

		self.InitializedPlayers[player.UserId] = nil
	end
end

function TeleportService:Teleport(player: Player, spawnpoint: string, options: { IgnoreGamepass: boolean }?)
	assert(player ~= nil, "Player is missing.")
	assert(spawnpoint ~= nil, "Spawnpoint is missing.")

	if not options or not options.IgnoreGamepass then
		local ownsGamepass = false
		self.MonetizationService
			:DoOwnGamepass(player, 671455721)
			:andThen(function(value)
				ownsGamepass = value
			end)
			:catch(warn)
			:await()
		if not ownsGamepass then
			self.NotificationsService:new(player, {
				text = "You must own a teleport game pass to be able to teleport.",
				title = "Teleport game pass required",
				duration = 15,
				type = "warn",
			})
			return self.MonetizationService:BuyGamepass(player, 671455721)
		end
	end

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
