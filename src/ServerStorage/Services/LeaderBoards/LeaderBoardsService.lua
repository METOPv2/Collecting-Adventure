local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.knit)

local FruitBucksDataBase: OrderedDataStore = DataStoreService:GetOrderedDataStore("LeaderBoards", "FruitBucks")
local PlayedTimeDataBase: OrderedDataStore = DataStoreService:GetOrderedDataStore("LeaderBoards", "PlayedTime")

local function ConvertTime(seconds: number): string
	if seconds < 60 then
		return tostring(seconds) .. " s."
	end

	local units = {
		"m",
		"h",
		"d",
		"w",
	}

	local i = 0
	repeat
		i += 1
		if i == 1 or i == 2 then
			seconds /= 60
		elseif i == 3 then
			seconds /= 24
		else
			seconds /= 7
		end
	until i == 4 or seconds < 60

	seconds = math.round(seconds * 10) / 10

	return tostring(seconds) .. " " .. units[i] .. "."
end

local LeaderBoardsService = Knit.CreateService({
	Name = "LeaderBoardsService",
})

function LeaderBoardsService:KnitInit()
	self.PlayerDataService = Knit.GetService("PlayerDataService")
	self.PlayerDataService.InitializedPlayer:Connect(function(playerID: number, playerData)
		PlayedTimeDataBase:SetAsync(
			tostring(playerID),
			math.round(workspace:GetServerTimeNow() - playerData.PlayedTime)
		)

		FruitBucksDataBase:SetAsync(tostring(playerID), math.round(playerData.AllTimeFruitBucks))

		self:InitializeLeaderBoards()
	end)
end

function LeaderBoardsService:InitializeLeaderBoards()
	local success, data: DataStorePages = pcall(function()
		return FruitBucksDataBase:GetSortedAsync(false, 100)
	end)

	if not success then
		warn(data)
		task.delay(3, function()
			self:InitializeLeaderBoards()
		end)
		return
	else
		local LeaderBoard: Model = workspace.LeaderBoards.FruitBucksLeaderBoard
		local Holder: ScrollingFrame = LeaderBoard.Main.SurfaceGui.ScrollingFrame
		local Template: Frame = LeaderBoard.Template

		for _, v in ipairs(Holder:GetChildren()) do
			if v.ClassName == "Frame" then
				v:Destroy()
			end
		end

		for i, v in pairs(data:GetCurrentPage()) do
			local Clone: Frame = Template:Clone()
			Clone.Rank.Text = "#" .. i
			Clone.Username.Text = "@" .. Players:GetNameFromUserIdAsync(v.key)
			Clone.Value.Text = v.value
			Clone.Parent = Holder
		end
	end

	success, data = pcall(function()
		return PlayedTimeDataBase:GetSortedAsync(false, 100)
	end)

	if not success then
		warn(data)
		task.delay(3, function()
			self:InitializeLeaderBoards()
		end)
		return
	else
		local LeaderBoard: Model = workspace.LeaderBoards.TimeLeaderBoard
		local Holder: ScrollingFrame = LeaderBoard.Main.SurfaceGui.ScrollingFrame
		local Template: Frame = LeaderBoard.Template

		for _, v in ipairs(Holder:GetChildren()) do
			if v.ClassName == "Frame" then
				v:Destroy()
			end
		end

		for i, v in pairs(data:GetCurrentPage()) do
			local Clone: Frame = Template:Clone()
			Clone.Rank.Text = "#" .. i
			Clone.Username.Text = "@" .. Players:GetNameFromUserIdAsync(v.key)
			Clone.Value.Text = ConvertTime(v.value)
			Clone.Parent = Holder
		end
	end
end

return LeaderBoardsService
