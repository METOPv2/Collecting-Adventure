-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

-- Player
local localPlayer = Players.LocalPlayer

-- Tags controller
local TagsController = Knit.CreateController({
	Name = "TagsController",
	TagAdded = Signal.new(),
	TagEquipped = Signal.new(),
	TagUnequipped = Signal.new(),
	TagRemoved = Signal.new(),
	_CharacterConnections = {},
	_InitializedTags = {},
})

function TagsController:KnitInit()
	self.PlayerDataController = Knit.GetController("PlayerDataController")

	for _, player in ipairs(Players:GetPlayers()) do
		coroutine.wrap(self.InitializePlayer)(self, player)
	end

	Players.PlayerAdded:Connect(function(player)
		self:InitializePlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:DeInitializePlayer(player)
	end)
end

function TagsController:InitializePlayer(player: Player)
	if player.Character then
		self:DisableHumanoidDisplayName(player.Character)
		if player ~= localPlayer then
			self:AddTag(player)
		end
	end

	self._CharacterConnections[player.UserId] = {}

	local characterAdded = player.CharacterAdded:Connect(function(character)
		task.defer(function()
			self:DisableHumanoidDisplayName(character)
			if player ~= localPlayer then
				self:AddTag(player)
			end
		end)
	end)

	local characterRemoving = player.CharacterRemoving:Connect(function()
		self:RemoveTag(player)
	end)

	table.insert(self._InitializedTags, characterAdded)
	table.insert(self._InitializedTags, characterRemoving)
end

function TagsController:DeInitializePlayer(player: Player)
	for i, connection: RBXScriptConnection in ipairs(self._CharacterConnections) do
		connection:Disconnect()
		self._CharacterConnections[player.UserId][i] = nil
	end
	self._CharacterConnections[player.UserId] = nil
end

function TagsController:DisableHumanoidDisplayName(character: Model?)
	if not character then
		if not localPlayer.Character then
			localPlayer.CharacterAdded:Wait()
		end

		character = localPlayer.Character
	end

	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
end

function TagsController:AddTag(player: Player)
	if self._InitializedTags[player.UserId] then
		return
	end

	local character: Model = player.Character
	local root = character:WaitForChild("HumanoidRootPart")

	local tag = Instance.new("BillboardGui")
	tag.AlwaysOnTop = true
	tag.Size = UDim2.fromOffset(200, 40)
	tag.ClipsDescendants = false
	tag.Name = "Tag"
	tag.StudsOffsetWorldSpace = Vector3.new(0, character:GetExtentsSize().Y / 2 + 0.5, 0)
	tag.LightInfluence = 0
	tag.MaxDistance = 100
	tag.Parent = root

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.FillDirection = Enum.FillDirection.Vertical
	uIListLayout.SortOrder = Enum.SortOrder.Name
	uIListLayout.Parent = tag

	local label = Instance.new("TextLabel")
	label.AutomaticSize = Enum.AutomaticSize.XY
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Text = player.DisplayName
	label.TextSize = 16
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.Ubuntu
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.Name = 1
	label.Parent = tag

	local fruitBucks = Instance.new("TextLabel")
	fruitBucks.AutomaticSize = Enum.AutomaticSize.XY
	fruitBucks.BackgroundTransparency = 1
	fruitBucks.BorderSizePixel = 0
	fruitBucks.Text = `Fruit bucks: {self.PlayerDataController:GetPlayerData(player.UserId).FruitBucks}`
	fruitBucks.TextSize = 12
	fruitBucks.TextColor3 = Color3.fromRGB(255, 255, 255)
	fruitBucks.TextStrokeTransparency = 0
	fruitBucks.Font = Enum.Font.Ubuntu
	fruitBucks.AnchorPoint = Vector2.new(0.5, 0.5)
	fruitBucks.Position = UDim2.fromScale(0.5, 0.5)
	fruitBucks.Name = 2
	fruitBucks.Parent = tag

	local level = Instance.new("TextLabel")
	level.AutomaticSize = Enum.AutomaticSize.XY
	level.BackgroundTransparency = 1
	level.BorderSizePixel = 0
	level.Text = `Level: {self.PlayerDataController:GetPlayerData(player.UserId).Level}`
	level.TextSize = 12
	level.TextColor3 = Color3.fromRGB(255, 255, 255)
	level.TextStrokeTransparency = 0
	level.Font = Enum.Font.Ubuntu
	level.AnchorPoint = Vector2.new(0.5, 0.5)
	level.Position = UDim2.fromScale(0.5, 0.5)
	level.Name = 3
	level.Parent = tag

	local connection = self.PlayerDataController.NotLocalDataChanged:Connect(function(player2, key, value)
		if player2 == player then
			if key == "FruitBucks" then
				fruitBucks.Text = `FruitBucks: {value}`
			elseif key == "Level" then
				level.Text = `Level: {value}`
			end
		end
	end)

	self._InitializedTags[player.UserId] = {
		tag = tag,
		connection = connection,
	}
end

function TagsController:RemoveTag(player: Player)
	if self._InitializedTags[player.UserId] then
		self._InitializedTags[player.UserId].connection:Disconnect()
		self._InitializedTags[player.UserId].tag:Destroy()
		self._InitializedTags[player.UserId] = nil
	end
end

return TagsController
