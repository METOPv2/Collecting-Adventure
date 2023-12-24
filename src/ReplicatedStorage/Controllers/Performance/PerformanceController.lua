local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

local PerformanceController = Knit.CreateController({
	Name = "PerformanceController",
	LowPerformanceMode = nil,
	Cache = {},
	Debounce = false,
	PerformanceApplied = Signal.new(),
})

function PerformanceController:KnitInit()
	self.SettingsController = Knit.GetController("SettingsController")
end

function PerformanceController:KnitStart()
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	self.LowPerformanceMode = self.SettingsController:GetSetting("LowPerformanceMode")
	self:ApplyPerformance()
	self.SettingsController.SettingChanged:Connect(function(key, value)
		if key == "LowPerformanceMode" then
			self.LowPerformanceMode = value
			self:ApplyPerformance()
		end
	end)
end

function PerformanceController:ApplyPerformance()
	if self.Debounce then
		self.LowPerformanceMode:Wait()
	end
	self.Debounce = true
	if self.LowPerformanceMode then
		Lighting.GlobalShadows = false
		self.Cache.Decals = {}
		for _, v in ipairs(workspace:WaitForChild("Map").Walls:GetDescendants()) do
			if v.ClassName == "Decal" then
				self.Cache.Decals[v] = v.Parent
				v.Parent = nil
			end
		end
		self.Cache.Trees = {}
		for _, v in ipairs(workspace:WaitForChild("Map").Trees:GetChildren()) do
			self.Cache.Trees[v] = v.Parent
			v.Parent = nil
		end
		self.Cache.Rocks = {}
		for _, v in ipairs(workspace:WaitForChild("Map").Rocks:GetChildren()) do
			self.Cache.Rocks[v] = v.Parent
			v.Parent = nil
		end
		self.Cache.Snow = {}
		for _, v in ipairs(workspace:WaitForChild("Map").Snow:GetChildren()) do
			self.Cache.Snow[v] = v.Parent
			v.Parent = nil
		end
		self.Cache.Piles = {}
		for _, v in ipairs(workspace:WaitForChild("Map").Piles:GetChildren()) do
			self.Cache.Piles[v] = v.Parent
			v.Parent = nil
		end
		self.Cache.Grass = {}
		for _, v in ipairs(workspace:WaitForChild("Map").Grass:GetChildren()) do
			self.Cache.Grass[v] = v.Parent
			v.Parent = nil
		end
	else
		Lighting.GlobalShadows = true
		if self.Cache.Decals then
			for v, parent in pairs(self.Cache.Decals) do
				v.Parent = parent
				self.Cache.Decals[v] = nil
			end
			self.Cache.Decals = nil
		end
		if self.Cache.Trees then
			for v, parent in pairs(self.Cache.Trees) do
				v.Parent = parent
				self.Cache.Trees[v] = nil
			end
			self.Cache.Trees = nil
		end
		if self.Cache.Rocks then
			for v, parent in pairs(self.Cache.Rocks) do
				v.Parent = parent
				self.Cache.Rocks[v] = nil
			end
		end
		if self.Cache.Snow then
			for v, parent in pairs(self.Cache.Snow) do
				v.Parent = parent
				self.Cache.Snow[v] = nil
			end
			self.Cache.Snow = nil
		end
		if self.Cache.Piles then
			for v, parent in pairs(self.Cache.Piles) do
				v.Parent = parent
				self.Cache.Piles[v] = nil
			end
			self.Cache.Piles = nil
		end
		if self.Cache.Grass then
			for v, parent in pairs(self.Cache.Grass) do
				v.Parent = parent
				self.Cache.Grass[v] = nil
			end
			self.Cache.Grass = nil
		end
	end

	self.Debounce = false
	self.PerformanceApplied:Fire()
end

return PerformanceController
