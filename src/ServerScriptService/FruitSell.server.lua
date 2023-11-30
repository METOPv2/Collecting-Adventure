-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.knit)

-- Data bases
local FruitsDataBase = require(ServerStorage.Source.DataBases.Fruits)

-- Sell
local sellParts: Folder = workspace.SellParts
local sellDebounce = {}

-- Functions
local function Touched(otherPart)
	local character = otherPart.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	local playerId = tostring(player.UserId)
	if sellDebounce[playerId] then
		return
	end
	sellDebounce[playerId] = true

	local SFXService = Knit.GetService("SFXService")
	local NotificationsService = Knit.GetService("NotificationsService")
	local PlayerDataService = Knit.GetService("PlayerDataService")
	local Fruits = PlayerDataService:GetAsync(player, "Fruits")

	if #Fruits ~= 0 then
		local fruitBucks, fruits = 0, 0
		for _, fruit in pairs(Fruits) do
			local fruitData = FruitsDataBase[fruit.Id]
			PlayerDataService:RemoveAsync(player, "Fruits", fruit)
			PlayerDataService:IncrementAsync(player, "FruitBucks", fruitData.SellValue)
			fruitBucks += fruitData.SellValue
			fruits += 1
		end
		NotificationsService:new(player, {
			text = `You earned {fruitBucks} fruit bucks for selling {fruits} fruit{fruits > 1 and "s" or ""}.`,
			title = "Fruits Sold",
			duration = 10,
			type = "sell",
		})
		SFXService:PlayLocalSFX(player, "CashRegister")
	end

	sellDebounce[playerId] = nil
end

-- Wait knit to load
Knit.OnStart():await()

-- Initialize sell parts
for _, part: Part in ipairs(sellParts:GetChildren()) do
	part.Touched:Connect(Touched)
end
