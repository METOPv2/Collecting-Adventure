-- Services
local Debris = game:GetService("Debris")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage:WaitForChild("Packages").knit)
local Signal = require(ReplicatedStorage:WaitForChild("Packages").signal)

-- Player
local localPlayer = Players.LocalPlayer

-- Types
type Settings = {
	Key: string,
	Distance: number?,
}

-- Marker controller
local MarkerController = Knit.CreateController({
	Name = "MarkerController",
	MarkFinished = Signal.new(),
	Keys = {},
})

function MarkerController:KnitInit()
	self.NotificationsController = Knit.GetController("NotificationsController")
	self.MarkerService = Knit.GetService("MarkerService")
	self.PlayerDataController = Knit.GetController("PlayerDataController")
	self.PlayerEquipmentController = Knit.GetController("PlayerEquipmentController")

	self.MarkerService.New:Connect(function(point, settings)
		self:New(point, settings)
	end)

	local marks = Instance.new("Folder")
	marks.Name = "Marks"
	marks.Parent = workspace
	self.Holder = marks
end

function MarkerController:KnitStart()
	if
		#self.PlayerDataController:GetAsync("Fruits")
		>= self.PlayerEquipmentController:GetBagData(self.PlayerEquipmentController:GetEquippedBag()).MaxFruits
	then
		self:New(workspace.SellParts, { Key = "Sell" })

		self.NotificationsController:new({
			text = "Sell your current fruits to have more capacity in your bag.",
			title = "Max fruits reached",
			duration = 15,
			type = "warn",
		})
	end
end

function MarkerController:New(point: Vector3 | Instance, settings: Settings): ()
	assert(point ~= nil, "Point is missing or nil.")
	assert(settings ~= nil, "Settings is missing or nil.")
	assert(settings.Key ~= nil, "Key is missing or nil.")

	local closeNotification = self.NotificationsController:new({
		text = `Mark "{settings.Key}" currently active. You can cancel it by clicking close button on this notification.`,
		title = "Active mark",
		onClose = function()
			self:Cancel(settings.Key)
		end,
		duration = -1,
		mode = "info",
	})

	if self.Keys[settings.Key] then
		self.Keys[settings.Key]()
	end

	local path: Path = PathfindingService:CreatePath({
		Costs = { ["Ground"] = 0, ["Grass"] = 100 },
	})

	local active = true
	local models = {}

	local vector3Point

	if typeof(point) ~= "Vector3" then
		vector3Point = self:GetClosestPoint(point)
	else
		vector3Point = point
	end

	local finishMark = Instance.new("BillboardGui")
	finishMark.AlwaysOnTop = true
	finishMark.MaxDistance = math.huge
	finishMark.Size = UDim2.fromOffset(100, 100)
	finishMark.StudsOffsetWorldSpace = Vector3.new(vector3Point)
	finishMark.Parent = workspace

	local markerImage = Instance.new("ImageLabel")
	markerImage.Image = "rbxassetid://15574942973"
	markerImage.Size = UDim2.fromScale(1, 1)
	markerImage.BackgroundTransparency = 1
	markerImage.BorderSizePixel = 0
	markerImage.Parent = finishMark

	local function disActivate()
		active = false
		coroutine.wrap(closeNotification)()
		finishMark:Destroy()
		for i, oldModel in ipairs(models) do
			oldModel:Destroy()
			models[i] = nil
		end
	end

	self.Keys[settings.Key] = disActivate

	coroutine.wrap(function()
		repeat
			finishMark.StudsOffsetWorldSpace = vector3Point
				+ Vector3.new(0, math.max(0, math.min(localPlayer:DistanceFromCharacter(vector3Point) - 50, 15), 5), 0)
			if localPlayer:DistanceFromCharacter(vector3Point) < (settings.Distance and settings.Distance or 10) then
				self:Cancel(settings.Key)
			end
			task.wait()
		until not active
	end)()

	coroutine.wrap(function()
		if not localPlayer.Character then
			localPlayer.CharacterAdded:Wait()
		end

		task.defer(function()
			local character = localPlayer.Character

			while active do
				if typeof(point) ~= "Vector3" then
					vector3Point = self:GetClosestPoint(point)
				end

				character = localPlayer.Character

				path:ComputeAsync(character:GetPivot().Position, vector3Point)

				local model = Instance.new("Model")
				model.Name = settings.Key
				model.Parent = self.Holder

				local newHighlight = Instance.new("Highlight")
				newHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				newHighlight.Parent = model

				table.insert(models, model)

				coroutine.wrap(function()
					local waypoints = path:GetWaypoints()
					for i, waypoint in ipairs(waypoints) do
						if not active then
							break
						end

						if waypoints[i + 1] == nil then
							continue
						end

						local newPart = Instance.new("Part")
						newPart.BrickColor = BrickColor.Red()
						newPart.Size = Vector3.new(1, 1, (waypoint.Position - waypoints[i + 1].Position).Magnitude)
						newPart.CFrame = CFrame.lookAt(waypoint.Position, waypoints[i + 1].Position)
						newPart.CFrame *= CFrame.new(0, 0, -(newPart.Size.Z / 2))
						newPart.Material = Enum.Material.Neon
						newPart.Anchored = true
						newPart.CanCollide = false
						newPart.CanTouch = false
						newPart.CanQuery = false
						newPart.Parent = model

						Debris:AddItem(newPart, 3)

						task.wait()
					end

					task.wait(3)

					if table.find(models, model) then
						table.remove(models, table.find(models, model))
						model:Destroy()
					end
				end)()

				task.wait(5)
			end
		end)
	end)()

	return disActivate
end

function MarkerController:Cancel(key: string)
	assert(key ~= nil, "Key is missing or nil.")
	if self.Keys[key] then
		coroutine.wrap(self.Keys[key])()
		self.Keys[key] = nil
		self.MarkFinished:Fire(key)
		self.MarkerService.MarkFinished:Fire(key)
	end
end

function MarkerController:GetClosestPoint(holder: Instance): Vector3
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	if holder:GetDescendants()[1] == nil then
		holder.DescendantAdded:Wait()
	end

	local closest

	for _, part: Part in ipairs(holder:GetDescendants()) do
		if part.ClassName ~= "Part" and part.ClassName ~= "MeshPart" then
			continue
		end

		if
			not closest
			or localPlayer:DistanceFromCharacter(part.Position) < localPlayer:DistanceFromCharacter(closest)
		then
			closest = part.Position
		end
	end

	return closest
end

return MarkerController
